import 'dart:io';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../common/util/loaders/loaders.dart';
import '../model/daily_note_model.dart';
import '../model/trip_comment_model.dart';
import '../model/trip_model.dart';
import 'trip_detail_provider.dart';
import 'trip_provider.dart';

part 'trip_form_provider.freezed.dart';
part 'trip_form_provider.g.dart';

// DB에서 불러온 여행 데이터를 화면에 보여줄 때 사용.
@freezed
abstract class TripFormState with _$TripFormState {
  const factory TripFormState({
    required TripModel trip,
    required List<DailyNoteModel> dailyNotes,
    required List<TripCommentModel> images,
    String? coverImagePath,
  }) = _TripFormState;
}

// ==========================================
// TripFormNotifier (여행 작성/수정 폼 상태 관리)
// ==========================================
@riverpod
class TripFormNotifier extends _$TripFormNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  List<TripCommentModel> _currentImages = [];
  String? _coverImagePath;

  List<TripCommentModel> get currentImages => _currentImages;
  String? get coverImagePath => _coverImagePath;

  // bool _isDeleting = false;
  // bool get isDeleting => _isDeleting;

  @override
  AsyncValue<TripFormState> build() {
    _currentImages = [];
    _coverImagePath = null;
    return AsyncData(
      TripFormState(
        trip: TripModel(id: null, title: '', place: '', note: ''),
        dailyNotes: [],
        images: _currentImages,
      ),
    );
  }

  TripFormState get _safeState {
    return state.value ??
        TripFormState(
          trip: TripModel(id: null, title: '', place: '', note: ''),
          dailyNotes: [],
          images: _currentImages, // 클래스 내 유지 중인 임시 이미지 리스트 사용
          coverImagePath: _coverImagePath,
        );
  }

  // 3. 기존의 _currentModel도 _safeState를 사용하면 에러가 안 납니다.
  TripModel get _currentModel => _safeState.trip;

  void updateDateWithValidation({
    required bool isStart,
    required DateTime picked,
    required BuildContext context,
  }) {
    final currentTrip = _safeState.trip;
    final newStart = isStart ? picked : currentTrip.startDate;
    final newEnd = isStart ? currentTrip.endDate : picked;

    if (newStart != null && newEnd != null) {
      final newDays = newEnd.difference(newStart).inDays + 1;
      if (newDays <= 0) {
        JLoaders.errorSnackBar(
          context,
          title: '오류',
          message: isStart ? '시작일은 종료일보다 앞서야 합니다.' : '종료일은 시작일보다 뒤여야 합니다.',
        );
        return;
      }
    }

    if (isStart) {
      updateStartDate(picked);
    } else {
      updateEndDate(picked);
    }
  }

  void updateStartDate(DateTime date) {
    final updatedTrip = _currentModel.copyWith(startDate: date);
    state = AsyncData(
      _generateDailyNotesIfNeeded(updatedTrip, _safeState.dailyNotes),
    );
  }

  void updateEndDate(DateTime date) {
    final updatedTrip = _currentModel.copyWith(endDate: date);
    state = AsyncData(
      _generateDailyNotesIfNeeded(updatedTrip, _safeState.dailyNotes),
    );
  }

  //사용자가 여행 시작일과 종료일을 선택했을 때, 그 기간에 맞는 DailyNote 리스트를 자동 생성합니다.
  //임시 데이터 생성기
  TripFormState _generateDailyNotesIfNeeded(
    TripModel trip,
    List<DailyNoteModel> currentNotes,
  ) {
    if (trip.startDate == null || trip.endDate == null) {
      return _safeState.copyWith(trip: trip);
    }

    final totalDays = trip.endDate!.difference(trip.startDate!).inDays + 1;
    if (totalDays <= 0) return _safeState.copyWith(trip: trip);

    final newDailyNotes = List.generate(totalDays, (index) {
      final dayCount = index + 1;
      return currentNotes.firstWhere(
        (note) => note.dayCount == dayCount,
        orElse: () => DailyNoteModel(
          id: 'day_$dayCount',
          tripId: trip.id,
          dayCount: dayCount,
          comment: '',
        ),
      );
    });

    return TripFormState(
      trip: trip,
      dailyNotes: newDailyNotes,
      images: _currentImages,
    );
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
      quality: 85,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.webp,
    );

    return result != null ? File(result.path) : null;
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
    state = AsyncData(
      _safeState.copyWith(
        trip: _currentModel.copyWith(),
        images: _currentImages, // 🔹 반영
      ),
    );
  }

  Future<void> addImagesFromGallery(List<XFile> pickedFiles) async {
    final tasks = pickedFiles.map(addImageFromGallery);
    await Future.wait(tasks); // ✅ 병렬 처리
  }

  void setCoverImage(String? path) {
    _coverImagePath = path;
    state = AsyncData(
      _safeState.copyWith(
        trip: _currentModel.copyWith(coverImagePath: path),
        images: List.from(_currentImages),
        coverImagePath: path,
      ),
    );
  }

  void removeImage(int index, {String? tripId}) async {
    if (tripId == null) {
      // 등록 화면 → UI 상태만 반영
      removeImageTemp(index);
    } else {
      // 수정 화면 → DB 반영 포함
      await removeImagePersist(index, tripId);
    }
  }

  void updateImageComment(int index, String comment, {String? tripId}) async {
    if (tripId == null) {
      updateImageCommentTemp(index, comment);
    } else {
      await updateImageCommentPersist(index, comment, tripId);
    }
  }

  /// 등록 화면: 이미지 삭제 (UI 상태만 반영)
  void removeImageTemp(int index) {
    if (index < 0 || index >= _currentImages.length) return;
    _currentImages = [..._currentImages]..removeAt(index);
    state = AsyncData(
      _safeState.copyWith(
        trip: _currentModel.copyWith(),
        images: List.from(_currentImages),
      ),
    );
  }

  /// 등록 화면: 이미지 코멘트 수정 (UI 상태만 반영)
  void updateImageCommentTemp(int index, String comment) {
    if (index < 0 || index >= _currentImages.length) return;
    final old = _currentImages[index];
    _currentImages = [..._currentImages];
    _currentImages[index] = old.copyWith(comment: comment);

    state = AsyncData(
      _safeState.copyWith(
        trip: _currentModel.copyWith(),
        images: List.from(_currentImages),
      ),
    );
  }

  /// 수정 화면: 이미지 삭제 (UI, DB 반영)
  Future<void> removeImagePersist(int index, String tripId) async {
    if (index < 0 || index >= _currentImages.length) return;

    // state = const AsyncLoading(); // UI에서 자동으로 로딩 표시됨(전체화면)

    // 1. 작업할 데이터 확보
    final imageToRemove = _currentImages[index];

    try {
      // 2. [DB] Firestore 문서 삭제
      if (imageToRemove.id != null) {
        await _firestore
            .collection(TripDbInfo.tableName)
            .doc(tripId)
            .collection(TripCommentDbInfo.tableName)
            .doc(imageToRemove.id)
            .delete();
      }

      // 3. [DB] Storage 파일 삭제
      if (imageToRemove.path.startsWith('http')) {
        try {
          final ref = _storage.refFromURL(imageToRemove.path);
          await ref.delete();
        } catch (e) {
          debugPrint('Storage 삭제 실패: $e');
        }
      }

      // 4. [상태] 로컬 리스트에서 제거
      _currentImages = List.from(_currentImages)..removeAt(index);

      // 5. [상태] 대표 이미지 삭제 처리 (매우 중요)
      // 현재 삭제하려는 이미지가 대표 이미지와 같다면 처리
      String? nextCoverPath = _coverImagePath;
      if (nextCoverPath == imageToRemove.path) {
        // 남은 이미지가 있다면 첫 번째 이미지를 새 대표로, 없다면 null
        nextCoverPath = _currentImages.isNotEmpty
            ? _currentImages.first.path
            : null;
      }
      _coverImagePath = nextCoverPath;

      // 6. [상태] Firestore의 여행 정보 문서에서도 대표 이미지 경로 업데이트
      await _firestore.collection(TripDbInfo.tableName).doc(tripId).update({
        'coverImagePath': nextCoverPath,
      });

      // 7. [상태] 최종 상태 갱신 (AsyncData)
      state = AsyncData(
        _safeState.copyWith(
          trip: _currentModel.copyWith(coverImagePath: nextCoverPath),
          images: List.from(_currentImages),
          coverImagePath: nextCoverPath,
        ),
      );
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// 수정 화면: 이미지 코멘트 수정 (Firestore 반영 포함)
  Future<void> updateImageCommentPersist(
    int index,
    String comment,
    String tripId,
  ) async {
    if (index < 0 || index >= _currentImages.length) return;

    // 로딩 시작
    state = const AsyncLoading();

    try {
      final old = _currentImages[index];
      final updated = old.copyWith(comment: comment);
      _currentImages = [..._currentImages];
      _currentImages[index] = updated;

      // Firestore 업데이트
      if (updated.id != null) {
        await _firestore
            .collection(TripDbInfo.tableName)
            .doc(tripId)
            .collection(TripCommentDbInfo.tableName)
            .doc(updated.id)
            .update({'comment': comment});
      }

      state = AsyncData(
        _safeState.copyWith(
          trip: _currentModel.copyWith(),
          images: List.from(_currentImages),
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void updateDailyNoteComment(int dayCount, String comment) {
    final updatedNotes = _safeState.dailyNotes.map((note) {
      if (note.dayCount == dayCount) {
        return note.copyWith(comment: comment);
      }
      return note;
    }).toList();

    state = AsyncData(_safeState.copyWith(dailyNotes: updatedNotes));
  }

  /// 🌟 [최적화 2] 파이어베이스 Firestore 및 Storage 업로드 통합 동기화 저장
  Future<void> save({
    required String title,
    required String place,
    required String note,
  }) async {
    try {
      // 1. [데이터 확보] 로딩 상태로 변경하기 전, 데이터를 먼저 안전하게 확보
      final currentState = state.value;
      if (currentState == null) {
        throw Exception("데이터가 준비되지 않았습니다.");
      }

      final model = currentState.trip;
      final dailyNotes = currentState.dailyNotes;

      if (model.startDate == null || model.endDate == null) {
        throw Exception("여행 기간이 설정되지 않았습니다.");
      }

      // 2. [상태 변경] 이제 Loading 상태로 전환 (이후엔 currentState나 _safeState를 참조하지 않음)
      state = const AsyncLoading();

      final tripIdStr =
          model.id ??
          "${place}_${DateFormat('yyyyMMdd').format(model.startDate!)}_${DateFormat('HHmmss').format(DateTime.now())}";

      // 3. [비즈니스 로직] 확보해둔 변수들 사용
      // _uploadComments 내부에서 _currentImages를 쓰고 있는데,
      // 이를 currentState.images로 바꾸는 것이 좋습니다.
      final uploadedMap = await _uploadComments(tripIdStr);

      // Map → List<TripCommentModel> 변환
      final uploadedComments = uploadedMap.entries.map((e) {
        // e.key = 로컬 경로, e.value = Storage URL
        final original = _currentImages.firstWhere(
          (c) => c.path == e.key,
          orElse: () => TripCommentModel(path: e.value, comment: ''),
        );
        return original.copyWith(
          tripId: tripIdStr,
          path: e.value, // Storage URL
          comment: original.comment, // ✅ 코멘트 유지
        );
      }).toList();

      String? coverImagePath = currentState.coverImagePath;

      // 대표 이미지가 null이면 첫 번째 업로드된 이미지 URL 사용
      if (coverImagePath == null && uploadedMap.isNotEmpty) {
        coverImagePath = uploadedMap.values.first;
      }

      // 대표 이미지가 로컬 경로라면 URL로 교체
      if (coverImagePath != null && coverImagePath.startsWith('/data/')) {
        coverImagePath =
            uploadedMap[coverImagePath] ?? uploadedMap.values.first;
      }

      // 4. [Firestore 저장]
      final finalModel = model.copyWith(
        id: tripIdStr,
        title: title.trim(),
        place: place.trim(),
        note: note.trim(),
        coverImagePath: coverImagePath,
      );

      await saveEntireTrip(finalModel, uploadedComments, dailyNotes);

      ref.invalidate(tripListProvider);
      ref.invalidate(tripDetailProvider(tripIdStr));

      state = AsyncData(
        TripFormState(
          trip: finalModel,
          dailyNotes: dailyNotes,
          images: uploadedComments,
          coverImagePath: coverImagePath,
        ),
      );

    } catch (e, st) {
      debugPrint("저장 실패: $e - $st");
      state = AsyncError(e, st);
    }
  }

  Future<Map<String, String>> _uploadComments(String tripIdStr) async {
    final tasks = _currentImages.map((comment) async {
      // 이미 URL이면 그대로 매핑
      if (comment.path.startsWith('http')) {
        return MapEntry(comment.path, comment.path);
      }

      // 로컬 파일 압축 후 업로드
      final compressedImg = await _compressImage(comment.path);
      if (compressedImg != null) {
        final uniqueId = Uuid().v4();
        final commentRef = _storage.ref().child(
          'comments/$tripIdStr/$uniqueId.webp',
        );
        await commentRef.putFile(compressedImg);

        final downloadUrl = await commentRef.getDownloadURL();
        return MapEntry(comment.path, downloadUrl);
      }

      return null;
    }).toList();

    // ✅ 병렬 업로드 실행
    final results = await Future.wait(tasks);

    // null 제거 후 Map으로 변환
    return Map.fromEntries(results.whereType<MapEntry<String, String>>());
  }

  void setTravel(
    TripModel travel,
    List<TripCommentModel> comments,
    List<DailyNoteModel> dailyNotes,
  ) {
    _currentImages = comments;
    _coverImagePath = travel.coverImagePath;
    state = AsyncData(
      TripFormState(
        trip: travel,
        dailyNotes: dailyNotes,
        images: _currentImages,
      ),
    );
  }

  //여행 전체 데이터를 Firestore에 최종 반영합니다.
  Future<void> saveEntireTrip(
    TripModel trip,
    List<TripCommentModel> comments,
    List<DailyNoteModel> notes,
  ) async {
    try {
      final batch = _firestore.batch();
      final tripDocRef = _firestore
          .collection(TripDbInfo.tableName)
          .doc(trip.id);

      batch.set(tripDocRef, trip.toJson(), SetOptions(merge: true));

      // 2. 코멘트 저장 (기존 코멘트 삭제 후 새로 추가)
      final commentsColRef = tripDocRef.collection(TripCommentDbInfo.tableName);
      final existingComments = await commentsColRef.get();

      for (var doc in existingComments.docs) {
        batch.delete(doc.reference);
      }

      for (int i = 0; i < comments.length; i++) {
        final comment = comments[i];
        final docRef = commentsColRef.doc(i.toString()); // 🔹 문서명 = 숫자 id
        final commentWithId = comment.copyWith(
          id: i.toString(), // 🔹 모델 id도 동일하게
          tripId: trip.id,
        );
        batch.set(docRef, commentWithId.toJson());
      }

      // 3. 일별 노트 저장
      final notesColRef = tripDocRef.collection(TripDailyNoteDbInfo.tableName);
      final existingNotes = await notesColRef.get();

      for (var doc in existingNotes.docs) {
        batch.delete(doc.reference);
      }
      for (var note in notes) {
        final noteDocRef = notesColRef.doc('day_${note.dayCount}');
        batch.set(
          noteDocRef,
          note.copyWith(tripId: trip.id).toJson(),
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    } catch (e, st) {
      debugPrint("!!! 배치 에러 상세: $e");
      debugPrint("!!! 에러 위치: $st");
      rethrow;
    }
  }
}
