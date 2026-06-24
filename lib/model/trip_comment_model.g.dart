// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TripCommentModel _$TripCommentModelFromJson(Map<String, dynamic> json) =>
    _TripCommentModel(
      id: (json['id'] as num?)?.toInt(),
      tripId: (json['tripId'] as num?)?.toInt(),
      path: json['path'] as String,
      comment: json['comment'] as String? ?? '',
    );

Map<String, dynamic> _$TripCommentModelToJson(_TripCommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'path': instance.path,
      'comment': instance.comment,
    };
