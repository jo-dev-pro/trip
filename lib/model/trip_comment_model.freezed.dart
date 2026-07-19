// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_comment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TripCommentModel {

 String? get id; String? get tripId;// 외래키 관계 연결용 ID
 String get path; String get comment;
/// Create a copy of TripCommentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripCommentModelCopyWith<TripCommentModel> get copyWith => _$TripCommentModelCopyWithImpl<TripCommentModel>(this as TripCommentModel, _$identity);

  /// Serializes this TripCommentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TripCommentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.path, path) || other.path == path)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,path,comment);

@override
String toString() {
  return 'TripCommentModel(id: $id, tripId: $tripId, path: $path, comment: $comment)';
}


}

/// @nodoc
abstract mixin class $TripCommentModelCopyWith<$Res>  {
  factory $TripCommentModelCopyWith(TripCommentModel value, $Res Function(TripCommentModel) _then) = _$TripCommentModelCopyWithImpl;
@useResult
$Res call({
 String? id, String? tripId, String path, String comment
});




}
/// @nodoc
class _$TripCommentModelCopyWithImpl<$Res>
    implements $TripCommentModelCopyWith<$Res> {
  _$TripCommentModelCopyWithImpl(this._self, this._then);

  final TripCommentModel _self;
  final $Res Function(TripCommentModel) _then;

/// Create a copy of TripCommentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? tripId = freezed,Object? path = null,Object? comment = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String?,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TripCommentModel].
extension TripCommentModelPatterns on TripCommentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TripCommentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TripCommentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TripCommentModel value)  $default,){
final _that = this;
switch (_that) {
case _TripCommentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TripCommentModel value)?  $default,){
final _that = this;
switch (_that) {
case _TripCommentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? tripId,  String path,  String comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TripCommentModel() when $default != null:
return $default(_that.id,_that.tripId,_that.path,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? tripId,  String path,  String comment)  $default,) {final _that = this;
switch (_that) {
case _TripCommentModel():
return $default(_that.id,_that.tripId,_that.path,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? tripId,  String path,  String comment)?  $default,) {final _that = this;
switch (_that) {
case _TripCommentModel() when $default != null:
return $default(_that.id,_that.tripId,_that.path,_that.comment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TripCommentModel implements TripCommentModel {
   _TripCommentModel({this.id, this.tripId, required this.path, this.comment = ''});
  factory _TripCommentModel.fromJson(Map<String, dynamic> json) => _$TripCommentModelFromJson(json);

@override final  String? id;
@override final  String? tripId;
// 외래키 관계 연결용 ID
@override final  String path;
@override@JsonKey() final  String comment;

/// Create a copy of TripCommentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripCommentModelCopyWith<_TripCommentModel> get copyWith => __$TripCommentModelCopyWithImpl<_TripCommentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TripCommentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TripCommentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.path, path) || other.path == path)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tripId,path,comment);

@override
String toString() {
  return 'TripCommentModel(id: $id, tripId: $tripId, path: $path, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$TripCommentModelCopyWith<$Res> implements $TripCommentModelCopyWith<$Res> {
  factory _$TripCommentModelCopyWith(_TripCommentModel value, $Res Function(_TripCommentModel) _then) = __$TripCommentModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? tripId, String path, String comment
});




}
/// @nodoc
class __$TripCommentModelCopyWithImpl<$Res>
    implements _$TripCommentModelCopyWith<$Res> {
  __$TripCommentModelCopyWithImpl(this._self, this._then);

  final _TripCommentModel _self;
  final $Res Function(_TripCommentModel) _then;

/// Create a copy of TripCommentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? tripId = freezed,Object? path = null,Object? comment = null,}) {
  return _then(_TripCommentModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String?,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
