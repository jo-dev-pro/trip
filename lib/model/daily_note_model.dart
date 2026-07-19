import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_note_model.freezed.dart';
part 'daily_note_model.g.dart';

@freezed
abstract class DailyNoteModel with _$DailyNoteModel {
  factory DailyNoteModel({
    String? id,
    String? tripId, // 외래키 관계 연결용 ID
    int? dayCount, // 날짜 카운트
    @Default('') String comment,
  }) = _DailyNoteModel;

  factory DailyNoteModel.fromJson(Map<String, dynamic> json) => _$DailyNoteModelFromJson(json);
}

// db 형식에 맞는 모델
class TripDailyNoteDbInfo {
  static String tableName = 'daily_note';
  static String id = 'id';
   static String tripId = 'tripId';
  static String dayCount = 'dayCount';
  static String comment = 'comment';
}