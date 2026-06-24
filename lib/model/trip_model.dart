import 'package:freezed_annotation/freezed_annotation.dart';
// 💡 TripCommentModel 임포트가 안 되어 있다면 추가해주세요.

part 'trip_model.freezed.dart';
part 'trip_model.g.dart';

@freezed
abstract class TripModel with _$TripModel {
  const TripModel._();

  factory TripModel({
    int? id,
    required String title,
    required String place,
    DateTime? startDate,
    DateTime? endDate,
    String? note,

  }) = _TripModel;

  factory TripModel.fromJson(Map<String, dynamic> json) => _$TripModelFromJson(json);
}


// db 형식에 맞는 모델
class TripDbInfo {
  static String tableName = 'trip';
  static String id = 'id';
  static String title = 'title';
  static String place = 'place';
  static String startDate = 'startDate';
  static String endDate = 'endDate';
  static String note = 'note';
}