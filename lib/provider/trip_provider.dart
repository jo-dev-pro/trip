import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // 💡 이미지 압축 모듈 임포트
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 Firestore 임포트
import 'package:firebase_storage/firebase_storage.dart'; // 💡 Storage 임포트

import '../model/daily_note_model.dart';
import '../model/trip_comment_model.dart';
import '../model/trip_model.dart';
import '../repository/repository.dart';
import 'trip_detail_state.dart';

part 'trip_provider.g.dart';

/// tripListProvider → 여행 목록 전체를 관리 (리스트 화면)

/// tripFormProvider → 여행 작성/수정 폼 상태 관리

/// tripDetailProvider → 특정 여행의 상세 정보 관리 (코멘트, 데일리노트 포함)

// ===============================================
// 1. TripList (파이어베이스 결합형 여행 목록 로더)
// ===============================================
@riverpod
class TripList extends _$TripList {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<List<TripModel>> build() async {
    return _fetchFromFirebase();
  }

  Future<List<TripModel>> _fetchFromFirebase() async {
    final querySnapshot = await _firestore
        .collection(TripDbInfo.tableName)
        .orderBy('startDate', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => TripModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _fetchFromFirebase());
  }

  Future<void> deleteTrip(int id) async {
    // 💡 1. 로컬 SQLite에서 지우는 동시에 파이어베이스 원격 문서도 제거
    // final localRepo = TripRepository();
    // await localRepo.deleteTrip(id);

    await _firestore
        .collection(TripDbInfo.tableName)
        .doc(id.toString())
        .delete();

    final tripDoc = _firestore
        .collection(TripDbInfo.tableName)
        .doc(id.toString());

    // 서브 컬렉션(comments, daily_notes)도 순차적으로 비웁니다.
    final commentSnapshot = await tripDoc
        .collection(TripCommentDbInfo.tableName)
        .get();
    for (var doc in commentSnapshot.docs) {
      await doc.reference.delete();
    }
    final noteSnapshot = await tripDoc
        .collection(TripDailyNoteDbInfo.tableName)
        .get();
    for (var doc in noteSnapshot.docs) {
      await doc.reference.delete();
    }

    await tripDoc.delete();

    // 💡 2. 스토리지 파일들도 일괄 삭제 (선택 사항이나 깔끔한 청소 위해 처리)
    try {
      final storageRef = FirebaseStorage.instance.ref().child('covers/$id');
      await storageRef.delete();
    } catch (_) {}

    await refresh();
  }
}

// ==========================================
// 2. TripFormNotifier (클라우드 최적화 이미지 업로드 폼 관리)
// ==========================================
@riverpod
class TripFormNotifier extends _$TripFormNotifier {
  final _repository = TripRepository();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  List<TripCommentModel> _currentImages = [];
  String? _coverImagePath;
  List<TripCommentModel> get currentImages => _currentImages;
  String? get coverImagePath => _coverImagePath;

  @override
  AsyncValue<TripFormState> build() {
    _currentImages = [];
    _coverImagePath = null;
    return AsyncData(
      TripFormState(
        trip: TripModel(id: null, title: '', place: '', note: ''),
        dailyNotes: [],
      ),
    );
  }

  TripFormState get _currentState => state.value!;
  TripModel get _currentModel => _currentState.trip;

  void updateStartDate(DateTime date) {
    final updatedTrip = _currentModel.copyWith(startDate: date);
    state = AsyncData(
      _generateDailyNotesIfNeeded(updatedTrip, _currentState.dailyNotes),
    );
  }

  void updateEndDate(DateTime date) {
    final updatedTrip = _currentModel.copyWith(endDate: date);
    state = AsyncData(
      _generateDailyNotesIfNeeded(updatedTrip, _currentState.dailyNotes),
    );
  }

  TripFormState _generateDailyNotesIfNeeded(
    TripModel trip,
    List<DailyNoteModel> currentNotes,
  ) {
    if (trip.startDate == null || trip.endDate == null) {
      return _currentState.copyWith(trip: trip);
    }

    final totalDays = trip.endDate!.difference(trip.startDate!).inDays + 1;
    if (totalDays <= 0) return _currentState.copyWith(trip: trip);

    final List<DailyNoteModel> newDailyNotes = List.generate(totalDays, (
      index,
    ) {
      final dayCount = index + 1;
      return currentNotes.firstWhere(
        (note) => note.dayCount == dayCount,
        orElse: () => DailyNoteModel(
          id: null,
          tripId: trip.id,
          dayCount: dayCount,
          comment: '',
        ),
      );
    });

    return TripFormState(trip: trip, dailyNotes: newDailyNotes);
  }

  void updateDailyNoteComment(int dayCount, String comment) {
    final updatedNotes = _currentState.dailyNotes.map((note) {
      return note.dayCount == dayCount ? note.copyWith(comment: comment) : note;
    }).toList();

    state = AsyncData(_currentState.copyWith(dailyNotes: updatedNotes));
  }

  /// 🌟 [최적화 1] 원본 업로드 속도 극대화용 프론트엔드 이미지 압축 알고리즘
  ///  - 한번에 올리기 때문에 파일명 시간으로 하면 안됨
  Future<File?> _compressImage(String sourcePath) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = p.join(tempDir.path, "${Uuid().v4()}_compressed.webp");

    // 해상도를 최대 1080px 범위로 리사이즈하며, 퀄리티를 75% 수준으로 고압축
    var result = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      quality: 75,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.webp,
    );

    if (result == null) return null;
    return File(result.path);
  }

  /// 갤러리 선택 이미지 추가 시 임시 로컬 캐시 처리
  Future<void> addImageFromGallery(XFile pickedFile) async {
    final comment = TripCommentModel(
      id: null,
      tripId: _currentModel.id,
      path: pickedFile.path, // 원본 주소로 대기시킨 후 save 시점에 압축 업로드 작동
      comment: '',
    );

    _currentImages = [..._currentImages, comment];
    state = AsyncData(_currentState.copyWith(trip: _currentModel.copyWith()));
  }

  Future<void> addImagesFromGallery(List<XFile> pickedFiles) async {
    for (final file in pickedFiles) {
      await addImageFromGallery(file);
    }
  }

  void setCoverImage(String? path) {
    _coverImagePath = path;
    state = AsyncData(_currentState.copyWith(trip: _currentModel.copyWith()));
  }

  void removeImage(int index) {
    if (index < 0 || index >= _currentImages.length) return;
    _currentImages = [..._currentImages]..removeAt(index);
    state = AsyncData(_currentState.copyWith(trip: _currentModel.copyWith()));
  }

  void updateImageComment(int index, String comment) {
    if (index < 0 || index >= _currentImages.length) return;
    final old = _currentImages[index];
    _currentImages = [..._currentImages];
    _currentImages[index] = old.copyWith(comment: comment);
    state = AsyncData(_currentState.copyWith(trip: _currentModel.copyWith()));
  }

  /// 🌟 [최적화 2] 파이어베이스 Firestore 및 Storage 업로드 통합 동기화 저장
  Future<void> save({
    required String title,
    required String place,
    required String note,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedPlace = place.trim();
    final trimmedNote = note.trim();

    final currentState = _currentState;
    final model = currentState.trip;
    final dailyNotes = currentState.dailyNotes;

    if (trimmedPlace.isEmpty || trimmedTitle.isEmpty) {
      state = AsyncError('모든 필드를 입력해 주세요.', StackTrace.current);
      return;
    }
    if (model.startDate == null || model.endDate == null) {
      state = AsyncError('여행 기간을 선택해주세요.', StackTrace.current);
      return;
    }

    state = const AsyncLoading();

    try {
      // 1. 임시 ID 또는 기존 고유 ID 확보
      final int savedTripId = model.id ?? DateTime.now().millisecondsSinceEpoch;
      final String tripIdStr = savedTripId.toString();

      // 2. 대표 이미지 업로드 처리 (수정되었거나 새로 지정된 경우)
      String? finalCoverUrl = _coverImagePath;
      if (_coverImagePath != null && !_coverImagePath!.startsWith('http')) {
        final compressedFile = await _compressImage(_coverImagePath!);
        if (compressedFile != null) {
          final coverRef = _storage.ref().child('covers/$tripIdStr');
          await coverRef.putFile(compressedFile);
          finalCoverUrl = await coverRef.getDownloadURL();
        }
      } else if (_coverImagePath == null && _currentImages.isNotEmpty) {
        // 대표 이미지가 수동 지정되지 않았다면 첫 이미지 자동 매핑 업로드 준비
        final firstPath = _currentImages.first.path;
        if (!firstPath.startsWith('http')) {
          final compressedFile = await _compressImage(firstPath);
          if (compressedFile != null) {
            final coverRef = _storage.ref().child('covers/$tripIdStr');
            await coverRef.putFile(compressedFile);
            finalCoverUrl = await coverRef.getDownloadURL();
          }
        } else {
          finalCoverUrl = firstPath;
        }
      }

      // 3. 서브 사진 목록 전체 압축 및 업로드 처리
      final uploadTasks = _currentImages.asMap().entries.map((entry) async {
        final index = entry.key;
        final comment = entry.value;

        if (comment.path.startsWith('http')) {
          return comment.copyWith(tripId: savedTripId);
        }

        final compressedImg = await _compressImage(comment.path);

        if (compressedImg != null) {
          final uniqueId = '${Uuid().v4()}_$index';
          final commentRef = _storage.ref().child(
            'comments/$tripIdStr/$uniqueId.webp',
          );
          await commentRef.putFile(compressedImg);
          final downloadUrl = await commentRef.getDownloadURL();

          return comment.copyWith(
            tripId: savedTripId,
            path: downloadUrl,
            comment: comment.comment,
          );
        }
        return null;
      }).toList();

      final uploadedComments = (await Future.wait(
        uploadTasks,
      )).whereType<TripCommentModel>().toList();

      // ✅ path 기준 중복 제거 - 동일 이미지 중복 방지 최종 결과물 distinctcomments
      final distinctComments = {
        for (var c in uploadedComments) c.path: c,
      }.values.toList();

      // final List<TripCommentModel> uploadedComments = [];
      // for (int i = 0; i < _currentImages.length; i++) {
      //   final comment = _currentImages[i];
      //   if (comment.path.startsWith('http')) {
      //     uploadedComments.add(comment.copyWith(tripId: savedTripId));
      //     continue;
      //   }

      //   // 실시간 원격 다이어트 압축 실행
      //   final compressedImg = await _compressImage(comment.path);
      //   if (compressedImg != null) {
      //     final uniqueId = '${DateTime.now().microsecondsSinceEpoch}_$i';
      //     final commentRef = _storage.ref().child('comments/$tripIdStr/$uniqueId.jpg');
      //     await commentRef.putFile(compressedImg);
      //     final downloadUrl = await commentRef.getDownloadURL();

      //     uploadedComments.add(comment.copyWith(
      //       tripId: savedTripId,
      //       path: downloadUrl, // 폰 주소를 영구적인 웹 주소로 치환 🌟
      //     ));
      //   }
      // }

      // 4. 파이어베이스 원격 메인 테이블 도큐먼트 기록 및 저장
      final tripDoc = _firestore
          .collection(TripDbInfo.tableName)
          .doc(tripIdStr);
      final finalModel = model.copyWith(
        id: savedTripId,
        title: trimmedTitle,
        place: trimmedPlace,
        note: trimmedNote,
        coverImagePath: finalCoverUrl,
      );

      await tripDoc.set({
        'id': finalModel.id,
        'title': finalModel.title,
        'place': finalModel.place,
        'startDate': finalModel.startDate?.toIso8601String(),
        'endDate': finalModel.endDate?.toIso8601String(),
        'note': finalModel.note,
        'coverImagePath': finalModel.coverImagePath ?? '',
      });

      // 5. 파이어베이스 서브 컬렉션(Comments) 일괄 저장
      // 기존 업로드된 컬렉션을 원격에서 비우고 새로 밀어 넣음 (무결성 보장)
      final commentsCol = tripDoc.collection(TripCommentDbInfo.tableName);
      final existingComments = await commentsCol.get();
      for (var doc in existingComments.docs) {
        await doc.reference.delete();
      }

      for (int i = 0; i < uploadedComments.length; i++) {
        final c = uploadedComments[i];
        await commentsCol.doc(i.toString()).set({
          'id': i,
          'tripId': savedTripId,
          'path': c.path,
          'comment': c.comment,
        });
      }

      // 6. 파이어베이스 서브 컬렉션(DailyNotes) 저장
      final notesCol = tripDoc.collection(TripDailyNoteDbInfo.tableName);
      final existingNotes = await notesCol.get();
      for (var doc in existingNotes.docs) {
        await doc.reference.delete();
      }

      for (final note in dailyNotes) {
        await notesCol.doc(note.dayCount.toString()).set({
          'id': note.dayCount,
          'tripId': savedTripId,
          'dayCount': note.dayCount,
          'comment': note.comment,
        });
      }

      await _repository.saveEntireTrip(
        finalModel,
        // uploadedComments,
        distinctComments,
        dailyNotes,
      );

      // 8. 강제 새로고침 리빌드 지시
      ref.invalidate(tripListProvider);
      ref.invalidate(tripFirstImageProvider(savedTripId));
      ref.invalidate(tripDetailProvider(savedTripId));

      state = AsyncData(
        TripFormState(trip: finalModel, dailyNotes: dailyNotes),
      );
    } catch (e) {
      state = AsyncError('클라우드 저장 실패: $e', StackTrace.current);
    }
  }

  void setTravel(
    TripModel travel,
    List<TripCommentModel> comments,
    List<DailyNoteModel> dailyNotes,
  ) {
    _currentImages = comments;
    _coverImagePath = travel.coverImagePath;
    state = AsyncData(TripFormState(trip: travel, dailyNotes: dailyNotes));
  }
}

// ==========================================
// 3. TripDetail (파이어베이스 결합형 상세 로더)
// ==========================================
@riverpod
class TripDetail extends _$TripDetail {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<TripDetailState> build(int tripId) async {
    return _loadTripDetailFromFirebase(tripId);
  }

  Future<TripDetailState> _loadTripDetailFromFirebase(int tripId) async {
    final tripDoc = _firestore
        .collection(TripDbInfo.tableName)
        .doc(tripId.toString());

    final tripGet = await tripDoc.get();
    if (!tripGet.exists) throw Exception("해당 일정을 원격지에서 찾을 수 없습니다.");
    final trip = TripModel.fromJson(tripGet.data()!);

    // 서브 컬렉션(comments) 획득
    final commentsSnapshot = await tripDoc
        .collection(TripCommentDbInfo.tableName)
        .get();
    final comments = commentsSnapshot.docs
        .map((doc) => TripCommentModel.fromJson(doc.data()))
        .toList();

    // 서브 컬렉션(daily_notes) 획득
    final notesSnapshot = await tripDoc
        .collection(TripDailyNoteDbInfo.tableName)
        .get();
    final dailyNotes = notesSnapshot.docs
        .map((doc) => DailyNoteModel.fromJson(doc.data()))
        .toList();

    dailyNotes.sort((a, b) => (a.dayCount ?? 0).compareTo(b.dayCount ?? 0));

    return TripDetailState(
      trip: trip,
      comments: comments,
      dailyNotes: dailyNotes,
    );
  }
  // add comment 에서 사용하는 용도
  Future<File?> _compressImage(String sourcePath) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = p.join(
      tempDir.path,
      "${Uuid().v4()}_compressed.webp", // UUID로 고유 파일명 보장
    );

    var result = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      quality: 75,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.webp,
    );

    if (result == null) return null;
    return File(result.path);
  }

  Future<void> addComment({
    required String path,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final tripDoc = _firestore
          .collection(TripDbInfo.tableName)
          .doc(tripId.toString());
      final commentsCol = tripDoc.collection(TripCommentDbInfo.tableName);

      // 새 이미지 물리 스토리지 업로드
      String remoteUrl = path;

      if (!path.startsWith('http')) {
        final compressedFile = await _compressImage(path);

        if (compressedFile != null) {
          final uniqueId = Uuid().v4(); // ✅ UUID로 고유화
          final ref = FirebaseStorage.instance.ref().child(
            'comments/$tripId/$uniqueId.webp',
          );
          await ref.putFile(compressedFile);
          remoteUrl = await ref.getDownloadURL();

          await ref.putFile(compressedFile);
          remoteUrl = await ref.getDownloadURL();
        }
        // final file = File(path);
        // final ref = FirebaseStorage.instance.ref().child(
        //   'comments/$tripId/${DateTime.now().microsecondsSinceEpoch}.jpg',
        // );
        // await ref.putFile(file);
        // remoteUrl = await ref.getDownloadURL();
      }

      final commentId = DateTime.now().millisecondsSinceEpoch.toString();
      await commentsCol.doc(commentId).set({
        'id': int.tryParse(commentId) ?? 0,
        'tripId': tripId,
        'path': remoteUrl,
        'comment': comment,
      });

      return _loadTripDetailFromFirebase(tripId);
    });
  }

  Future<void> updateCommentOnServer({
    required String commentId,
    required String newComment,
  }) async {
    final tripDoc = _firestore
        .collection(TripDbInfo.tableName)
        .doc(tripId.toString());
    final commentsCol = tripDoc.collection(TripCommentDbInfo.tableName);

    await commentsCol.doc(commentId).update({'comment': newComment});

    // tripDetailProvider 새로고침
    ref.invalidate(tripDetailProvider(tripId));
  }

  Future<void> saveDailyNote({
    required int dayCount,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final tripDoc = _firestore
          .collection(TripDbInfo.tableName)
          .doc(tripId.toString());
      await tripDoc
          .collection(TripDailyNoteDbInfo.tableName)
          .doc(dayCount.toString())
          .set({
            'id': dayCount,
            'tripId': tripId,
            'dayCount': dayCount,
            'comment': comment,
          }, SetOptions(merge: true));

      return _loadTripDetailFromFirebase(tripId);
    });
  }
}

@riverpod
Future<String?> tripFirstImage(Ref ref, int tripId) async {
  final firestore = FirebaseFirestore.instance;
  try {
    final doc = await firestore
        .collection(TripDbInfo.tableName)
        .doc(tripId.toString())
        .get();
    if (doc.exists) {
      final trip = TripModel.fromJson(doc.data()!);
      if (trip.coverImagePath != null && trip.coverImagePath!.isNotEmpty) {
        return trip.coverImagePath;
      }
    }

    final commentsSnapshot = await firestore
        .collection(TripDbInfo.tableName)
        .doc(tripId.toString())
        .collection(TripCommentDbInfo.tableName)
        .get();
    if (commentsSnapshot.docs.isNotEmpty) {
      return commentsSnapshot.docs.first.data()['path'] as String?;
    }
  } catch (e) {
    print('❌ [tripFirstImage] 파이어베이스 조회 실패 (tripId: $tripId): $e');
  }
  return null;
}
