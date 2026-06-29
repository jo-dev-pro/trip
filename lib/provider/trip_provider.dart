import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../model/daily_note_model.dart';
import '../model/trip_comment_model.dart';
import '../model/trip_model.dart';
import '../repository/repository.dart';
import 'trip_detail_state.dart';

part 'trip_provider.g.dart';

// ==========================================
// 1. TripList (여행 목록 상태 관리)
// ==========================================
@riverpod
class TripList extends _$TripList {
  final _repository = TripRepository();

  @override
  Future<List<TripModel>> build() async {
    return await _repository.getAllTrips();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _repository.getAllTrips());
  }

  Future<void> deleteTrip(int id) async {
    await _repository.deleteTrip(id);
    await refresh();
  }
}

// ==========================================
// 2. TripFormNotifier (여행 등록/수정 폼 폼 상태 관리)
// ==========================================
@riverpod
class TripFormNotifier extends _$TripFormNotifier {
  final _repository = TripRepository();
  List<TripCommentModel> _currentImages = [];
  String? _coverImagePath; // 💡 대표 이미지 경로
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

  // 일차별 상태 생성 유틸
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

  // 실시간 타이핑 갱신
  void updateDailyNoteComment(int dayCount, String comment) {
    final updatedNotes = _currentState.dailyNotes.map((note) {
      return note.dayCount == dayCount ? note.copyWith(comment: comment) : note;
    }).toList();

    state = AsyncData(_currentState.copyWith(dailyNotes: updatedNotes));
  }

  Future<void> addImageFromGallery(XFile pickedFile) async {
    final dir = await _getTravelImagesDir();
    final ext = p.extension(pickedFile.path);
    final fileName = '${const Uuid().v4()}$ext';
    final destPath = p.join(dir.path, fileName);

    await File(pickedFile.path).copy(destPath);

    final comment = TripCommentModel(
      id: null,
      tripId: _currentModel
          .id, // 기존 _currentModel getter 유지 혹은 _currentState.trip.id 사용
      path: destPath,
      comment: '',
    );

    // 1. 클래스 내부 로컬 변수인 _currentImages에 새로운 이미지 코멘트 추가
    _currentImages = [..._currentImages, comment];

    // 2. 💡 [중요] 전체 상태를 TripFormState 구조에 맞게 복사하여 리빌드 유도
    state = AsyncData(
      _currentState.copyWith(
        trip: _currentModel.copyWith(), // 리빌드를 강제하기 위한 얕은 복사
        // dailyNotes는 기존 상태 그대로 유지됩니다.
      ),
    );
  }

  Future<void> addImagesFromGallery(List<XFile> pickedFiles) async {
    for (final file in pickedFiles) {
      await addImageFromGallery(file);
    }
  }

  /// 💡 대표 이미지 지정/해제
  void setCoverImage(String? path) {
    _coverImagePath = path;
    state = AsyncData(_currentState.copyWith(trip: _currentModel.copyWith()));
  }

  void removeImage(int index) {
    if (index < 0 || index >= _currentImages.length) return;

    // 1. 로컬 이미지 리스트에서 삭제 처리
    _currentImages = [..._currentImages]..removeAt(index);

    // 2. 💡 TripFormState 구조에 맞게 상태 변경 전파
    state = AsyncData(
      _currentState.copyWith(
        trip: _currentModel.copyWith(), // UI 리빌드 강제 트리거
      ),
    );
  }

  void updateImageComment(int index, String comment) {
    if (index < 0 || index >= _currentImages.length) return;

    // 1. 로컬 이미지 리스트 내 특정 아이템 코멘트 수정
    final old = _currentImages[index];
    _currentImages = [..._currentImages];
    _currentImages[index] = old.copyWith(comment: comment);

    // 2. 💡 TripFormState 구조에 맞게 상태 변경 전파
    state = AsyncData(
      _currentState.copyWith(
        trip: _currentModel.copyWith(), // UI 리빌드 강제 트리거
      ),
    );
  }

  // 💡 TripFormNotifier 클래스 내부 최하단에 이 메서드를 추가합니다.
  Future<Directory> _getTravelImagesDir() async {
    // 1. 앱 전용 안전한 문서 보관소 경로 획득
    final appDir = await getApplicationDocumentsDirectory();

    // 2. 'travel_images' 폴더 경로 결합 (.../app_flutter/travel_images)
    final dir = Directory(p.join(appDir.path, 'travel_images'));

    // 3. 해당 폴더가 스마트폰에 진짜 존재하는지 확인 후, 없으면 물리 폴더 생성
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // 4. 안전하게 확보된 폴더 객체 반환
    return dir;
  }

  /// 여행 정보 최종 저장 메커니즘
  Future<void> save({
    required String title,
    required String place,
    required String note,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedPlace = place.trim();
    final trimmedNote = note.trim();

    // 💡 TripFormState 기반으로 모델 및 일차별 노트 추출
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
      final finalModel = model.copyWith(
        title: trimmedTitle,
        place: trimmedPlace,
        note: trimmedNote,
        // 💡 대표 이미지: 현재 등록된 이미지 중 coverImagePath가 지정된 것 우선, 없으면 첫 번째
        coverImagePath:
            _coverImagePath ??
            (_currentImages.isNotEmpty ? _currentImages.first.path : null),
      );

      int savedTripId;

      if (finalModel.id == null) {
        // [신규 등록인 경우]
        savedTripId = await _repository.saveTrip(finalModel);
      } else {
        // [기존 수정인 경우] 기간 축소 자동 노트 삭제 트랜잭션 실행
        savedTripId = finalModel.id!;
        await _repository.updateTripAndAdjustNotes(finalModel);
      }

      // 수정한 코멘트(이미지) 일괄 저장 호출
      await _repository.saveTripComments(savedTripId, _currentImages);

      // 💡 [수정 포인트]: UI에서 따로 파라미터로 넘길 필요 없이,
      // 상태 내부에 실시간 보관 중이던 dailyNotes 목록을 활용해 안정적으로 DB와 동기화합니다.
      for (final note in dailyNotes) {
        await _repository.insertDailyNote(
          note.copyWith(tripId: savedTripId), // 새로 발급된 혹은 기존의 tripId 주입
        );
      }

      // 💡 [추가 포인트 3]: 무효화(invalidate) 순서 정돈 및 디테일 새로고침 강제화
      // 1. 리스트 화면 프로바이더 무효화
      ref.invalidate(tripListProvider);

      // 2. 대표 이미지 프로바이더 무효화 → 홈 카드 이미지 즉시 갱신
      ref.invalidate(tripFirstImageProvider(savedTripId));

      // 3. 디테일 화면 프로바이더 무효화 및 즉시 새 데이터 로드 대기
      ref.invalidate(tripDetailProvider(savedTripId));
      await ref.read(tripDetailProvider(savedTripId).future);

      // 💡 최종 상태 역시 TripFormState 구조에 맞추어 갱신해 줍니다.
      state = AsyncData(
        TripFormState(
          trip: finalModel.copyWith(id: savedTripId),
          dailyNotes: dailyNotes
              .map((n) => n.copyWith(tripId: savedTripId))
              .toList(),
        ),
      );
    } catch (e) {
      state = AsyncError('데이터베이스 저장 실패: $e', StackTrace.current);
    }
  }

  // ──────────── 💡 수정화면 진입 시 기존 데이터 세팅 ────────────
  void setTravel(
    TripModel travel,
    List<TripCommentModel> comments,
    List<DailyNoteModel> dailyNotes,
  ) {
    _currentImages = comments;
    _coverImagePath = travel.coverImagePath; // 💡 기존 대표 이미지 복원
    state = AsyncData(TripFormState(trip: travel, dailyNotes: dailyNotes));
  }
}

// ==========================================
// 3. TripDetail (여행 상세 데이터 로드 및 상호작용)
// ==========================================
@riverpod
class TripDetail extends _$TripDetail {
  final _repository = TripRepository();

  @override
  Future<TripDetailState> build(int tripId) async {
    return _loadTripDetail(tripId);
  }

  /// 데이터베이스의 관계형 데이터를 한 번에 로딩 및 바인딩
  Future<TripDetailState> _loadTripDetail(int tripId) async {
    final trip = await _repository.getTripById(tripId);
    final comments = await _repository.getCommentsByTrip(tripId);
    final dailyNotes = await _repository.getDailyNotesByTrip(tripId);

    // 일차(dayCount) 기준으로 오름차순 정렬
    dailyNotes.sort((a, b) => (a.dayCount ?? 0).compareTo(b.dayCount ?? 0));

    if (trip == null) throw Exception("여행 정보를 찾을 수 없습니다.");

    return TripDetailState(
      trip: trip,
      comments: comments,
      dailyNotes: dailyNotes,
    );
  }

  /// [기능] 이미지 코멘트 실시간 추가 및 화면 갱신
  Future<void> addComment({
    required String path,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newComment = TripCommentModel(
        tripId: tripId,
        path: path,
        comment: comment,
      );

      final currentComments = state.value?.comments ?? [];
      final updatedComments = [...currentComments, newComment];

      // 개 개별 수정/추가가 녹아든 갱신 로직 호출
      await _repository.saveTripComments(tripId, updatedComments);

      return _loadTripDetail(tripId);
    });
  }

  /// [기능] 일자별 핵심 노트 신규(Insert) 및 수정(Update) 처리
  Future<void> saveDailyNote({
    required int dayCount,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentNotes = state.value?.dailyNotes ?? [];

      // 이미 로드된 메모 목록에서 동일한 일차가 있는지 스캔
      final existingNote = currentNotes.firstWhere(
        (note) => note.dayCount == dayCount,
        orElse: () => DailyNoteModel(
          id: null,
          tripId: tripId,
          dayCount: dayCount,
          comment: '',
        ),
      );

      if (existingNote.id == null) {
        // 고유 PK ID가 없으므로 새 노트를 DB에 신규 입력
        await _repository.insertDailyNote(
          DailyNoteModel(tripId: tripId, dayCount: dayCount, comment: comment),
        );
      } else {
        // 기존 행이 있으므로 카피본을 떠서 전용 고유 ID 기반으로 Update 작동
        await _repository.updateDailyNote(
          existingNote.copyWith(comment: comment),
        );
      }

      return _loadTripDetail(tripId);
    });
  }
}

/// 특정 여행 ID(tripId)에 등록된 대표 이미지 경로를 반환하는 함수형 프로바이더
/// ✨ coverImagePath → 없으면 첫 번째 comment.path 순으로 폴백
@riverpod
Future<String?> tripFirstImage(Ref ref, int tripId) async {
  final repository = TripRepository();
  try {
    final trip = await repository.getTripById(tripId);
    if (trip?.coverImagePath != null && trip!.coverImagePath!.isNotEmpty) {
      return trip.coverImagePath;
    }
    // 대표 이미지 미설정 시 첫 번째 이미지로 폴백
    final comments = await repository.getCommentsByTrip(tripId);
    if (comments.isNotEmpty) return comments.first.path;
  } catch (e) {
    print('❌ [tripFirstImage] DB 조회 실패 (tripId: $tripId): $e');
  }
  return null;
}
