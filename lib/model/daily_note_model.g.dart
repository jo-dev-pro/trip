// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DailyNoteModel _$DailyNoteModelFromJson(Map<String, dynamic> json) =>
    _DailyNoteModel(
      id: (json['id'] as num?)?.toInt(),
      tripId: (json['tripId'] as num?)?.toInt(),
      dayCount: (json['dayCount'] as num?)?.toInt(),
      comment: json['comment'] as String? ?? '',
    );

Map<String, dynamic> _$DailyNoteModelToJson(_DailyNoteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'dayCount': instance.dayCount,
      'comment': instance.comment,
    };
