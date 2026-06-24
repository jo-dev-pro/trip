// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_note_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DailyNoteModel {

 int? get id; int? get tripId;// 외래키 관계 연결용 ID
 int? get dayCount;// 날짜 카운트
 String get comment;
/// Create a copy of DailyNoteModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyNoteModelCopyWith<DailyNoteModel> get copyWith => _$DailyNoteModelCopyWithImpl<DailyNoteModel>(this as DailyNoteModel, _$identity);

  /// Serializes this DailyNoteModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyNoteModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.dayCount, dayCount) || other.dayCount == dayCount)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,dayCount,comment);

@override
String toString() {
  return 'DailyNoteModel(id: $id, tripId: $tripId, dayCount: $dayCount, comment: $comment)';
}


}

/// @nodoc
abstract mixin class $DailyNoteModelCopyWith<$Res>  {
  factory $DailyNoteModelCopyWith(DailyNoteModel value, $Res Function(DailyNoteModel) _then) = _$DailyNoteModelCopyWithImpl;
@useResult
$Res call({
 int? id, int? tripId, int? dayCount, String comment
});




}
/// @nodoc
class _$DailyNoteModelCopyWithImpl<$Res>
    implements $DailyNoteModelCopyWith<$Res> {
  _$DailyNoteModelCopyWithImpl(this._self, this._then);

  final DailyNoteModel _self;
  final $Res Function(DailyNoteModel) _then;

/// Create a copy of DailyNoteModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? tripId = freezed,Object? dayCount = freezed,Object? comment = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as int?,dayCount: freezed == dayCount ? _self.dayCount : dayCount // ignore: cast_nullable_to_non_nullable
as int?,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyNoteModel].
extension DailyNoteModelPatterns on DailyNoteModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyNoteModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyNoteModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyNoteModel value)  $default,){
final _that = this;
switch (_that) {
case _DailyNoteModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyNoteModel value)?  $default,){
final _that = this;
switch (_that) {
case _DailyNoteModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? tripId,  int? dayCount,  String comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyNoteModel() when $default != null:
return $default(_that.id,_that.tripId,_that.dayCount,_that.comment);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? tripId,  int? dayCount,  String comment)  $default,) {final _that = this;
switch (_that) {
case _DailyNoteModel():
return $default(_that.id,_that.tripId,_that.dayCount,_that.comment);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? tripId,  int? dayCount,  String comment)?  $default,) {final _that = this;
switch (_that) {
case _DailyNoteModel() when $default != null:
return $default(_that.id,_that.tripId,_that.dayCount,_that.comment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyNoteModel implements DailyNoteModel {
   _DailyNoteModel({this.id, this.tripId, this.dayCount, this.comment = ''});
  factory _DailyNoteModel.fromJson(Map<String, dynamic> json) => _$DailyNoteModelFromJson(json);

@override final  int? id;
@override final  int? tripId;
// 외래키 관계 연결용 ID
@override final  int? dayCount;
// 날짜 카운트
@override@JsonKey() final  String comment;

/// Create a copy of DailyNoteModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyNoteModelCopyWith<_DailyNoteModel> get copyWith => __$DailyNoteModelCopyWithImpl<_DailyNoteModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyNoteModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyNoteModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.dayCount, dayCount) || other.dayCount == dayCount)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,dayCount,comment);

@override
String toString() {
  return 'DailyNoteModel(id: $id, tripId: $tripId, dayCount: $dayCount, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$DailyNoteModelCopyWith<$Res> implements $DailyNoteModelCopyWith<$Res> {
  factory _$DailyNoteModelCopyWith(_DailyNoteModel value, $Res Function(_DailyNoteModel) _then) = __$DailyNoteModelCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? tripId, int? dayCount, String comment
});




}
/// @nodoc
class __$DailyNoteModelCopyWithImpl<$Res>
    implements _$DailyNoteModelCopyWith<$Res> {
  __$DailyNoteModelCopyWithImpl(this._self, this._then);

  final _DailyNoteModel _self;
  final $Res Function(_DailyNoteModel) _then;

/// Create a copy of DailyNoteModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? tripId = freezed,Object? dayCount = freezed,Object? comment = null,}) {
  return _then(_DailyNoteModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as int?,dayCount: freezed == dayCount ? _self.dayCount : dayCount // ignore: cast_nullable_to_non_nullable
as int?,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
