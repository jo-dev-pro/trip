import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/trip_comment_model.dart'; // SQLite용 모델 사용
import '../model/daily_note_model.dart';
import '../repository/repository.dart';
import 'trip_detail_state.dart';

part 'create_provider.g.dart';

@riverpod
@riverpod
class TripDetail extends _$TripDetail {
  // repository는 생성자나 build에서 주입받는 것을 권장합니다.
  late final TripRepository _repository = TripRepository();

  @override
  Future<TripDetailState> build(int tripId) async {
    return _loadTripDetail(tripId);
  }

  Future<TripDetailState> _loadTripDetail(int tripId) async {
    final trip = await _repository.getTripById(tripId);
    final comments = await _repository.getCommentsByTrip(tripId);
    final dailyNotes = await _repository.getDailyNotesByTrip(tripId);

    if (trip == null) throw Exception("해당 여행 정보를 찾을 수 없습니다.");

    return TripDetailState(trip: trip, comments: comments, dailyNotes: dailyNotes);
  }

  // [기능 1] 이미지 코멘트 추가
  Future<void> addComment({required String path, required String comment}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newComment = TripCommentModel(tripId: tripId, path: path, comment: comment);
      final currentComments = state.value?.comments ?? [];
      
      // 이제 리스트 전체를 다시 저장할 필요 없이, 레포지토리의 addComment 메서드 하나로 해결
      await _repository.addComment(tripId, newComment);
      
      return _loadTripDetail(tripId);
    });
  }

  // [기능 2] 일별 노트 저장 (추가/수정 통합)
  Future<void> saveDailyNote({required int dayCount, required String comment}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newNote = DailyNoteModel(
        tripId: tripId, 
        dayCount: dayCount, 
        comment: comment
      );
      
      // SQL처럼 INSERT/UPDATE를 직접 고민할 필요 없이 
      // Firestore의 set(merge: true)가 알아서 처리합니다.
      await _repository.saveDailyNote(newNote);
      
      return _loadTripDetail(tripId);
    });
  }
}
