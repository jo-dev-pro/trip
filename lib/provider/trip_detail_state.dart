import '../model/daily_note_model.dart';
import '../model/trip_comment_model.dart';
import '../model/trip_model.dart';

// UI에 한 번에 넘겨줄 결합형 상태 클래스
class TripDetailState {
  final TripModel trip;
  final List<TripCommentModel> comments;
  final List<DailyNoteModel> dailyNotes;

  TripDetailState({
    required this.trip,
    required this.comments,
    required this.dailyNotes,
  });
}

class TripFormState {
  final TripModel trip;
  final List<DailyNoteModel> dailyNotes;

  TripFormState({
    required this.trip,
    required this.dailyNotes,
  });

  TripFormState copyWith({
    TripModel? trip,
    List<DailyNoteModel>? dailyNotes,
  }) {
    return TripFormState(
      trip: trip ?? this.trip,
      dailyNotes: dailyNotes ?? this.dailyNotes,
    );
  }
}