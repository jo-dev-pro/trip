import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/trip_comment_model.dart'; // SQLite용 모델 사용
import '../model/daily_note_model.dart';
import '../repository/repository.dart';
import 'trip_detail_state.dart';

part 'create_provider.g.dart';

@riverpod
class TripDetail extends _$TripDetail {
  late final TripRepository _repository;

  @override
  Future<TripDetailState> build(int tripId) async {
    _repository =
        TripRepository(); // 실제 앱에서는 Repository 프로바이더를 watch하는 것을 권장합니다.

    return _loadTripDetail(tripId);
  }

  // 데이터베이스에서 해당 여행의 모든 기록을 한 번에 로드하는 메서드
  Future<TripDetailState> _loadTripDetail(int tripId) async {
    final trip = await _repository.getTripById(tripId);
    final comments = await _repository.getCommentsByTrip(tripId);

    // 일별 코멘트(DailyNote)를 dayCount 기준으로 정렬하여 가져오기
    final dailyNotes = await _repository.getDailyNotesByTrip(tripId);
    dailyNotes.sort((a, b) => (a.dayCount ?? 0).compareTo(b.dayCount ?? 0));

    if (trip == null) {
      throw Exception("해당 여행 정보를 찾을 수 없습니다.");
    }

    return TripDetailState(
      trip: trip,
      comments: comments,
      dailyNotes: dailyNotes,
    );
  }

  // [기능 1] 이미지 코멘트 추가
  Future<void> addComment({
    required String path,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. 새 코멘트 객체 생성
      final newComment = TripCommentModel(
        tripId: tripId,
        path: path,
        comment: comment,
      );

      // 2. 현재 상태(State)에 이미 로드되어 있는 기존 코멘트 리스트를 가져옵니다.
      final currentComments = state.value?.comments ?? [];

      // 3. 기존 리스트에 새 코멘트를 추가한 새로운 리스트를 만듭니다.
      final updatedComments = [...currentComments, newComment];

      // 4. 레포지토리의 saveTripComments에 리스트 형태로 전달합니다.
      await _repository.saveTripComments(tripId, updatedComments);

      // 5. 최신 데이터로 화면 새로고침
      return _loadTripDetail(tripId);
    });
  }

  // [기능 2] 일별 노트 저장 (추가 또는 수정)
  Future<void> saveDailyNote({
    required int dayCount,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentNotes = state.value?.dailyNotes ?? [];

      // 이미 같은 dayCount를 가진 노트가 있는지 선조회
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
        // 새 일차 작성 (INSERT)
        final newNote = DailyNoteModel(
          tripId: tripId,
          dayCount: dayCount,
          comment: comment,
        );
        await _repository.insertDailyNote(newNote);
      } else {
        // 기존 일차 수정 (UPDATE)
        final updatedNote = existingNote.copyWith(comment: comment);
        await _repository.updateDailyNote(updatedNote);
      }

      return _loadTripDetail(tripId);
    });
  }
}
