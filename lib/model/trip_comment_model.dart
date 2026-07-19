import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_comment_model.freezed.dart';
part 'trip_comment_model.g.dart';

@freezed
abstract class TripCommentModel with _$TripCommentModel {
  factory TripCommentModel({
    String? id,
    String? tripId, // 외래키 관계 연결용 ID
    required String path,
    @Default('') String comment,
  }) = _TripCommentModel;

  factory TripCommentModel.fromJson(Map<String, dynamic> json) => _$TripCommentModelFromJson(json);
}

// db 형식에 맞는 모델
class TripCommentDbInfo {
  static String tableName = 'comments';
  static String id = 'id';
  static String tripId = 'tripId';
  static String path = 'path';
  static String comment = 'comment';
}

