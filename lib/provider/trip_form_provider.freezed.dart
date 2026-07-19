// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_form_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TripFormState {

 TripModel get trip; List<DailyNoteModel> get dailyNotes; List<TripCommentModel> get images; String? get coverImagePath;
/// Create a copy of TripFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripFormStateCopyWith<TripFormState> get copyWith => _$TripFormStateCopyWithImpl<TripFormState>(this as TripFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TripFormState&&(identical(other.trip, trip) || other.trip == trip)&&const DeepCollectionEquality().equals(other.dailyNotes, dailyNotes)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.coverImagePath, coverImagePath) || other.coverImagePath == coverImagePath));
}


@override
int get hashCode => Object.hash(runtimeType,trip,const DeepCollectionEquality().hash(dailyNotes),const DeepCollectionEquality().hash(images),coverImagePath);

@override
String toString() {
  return 'TripFormState(trip: $trip, dailyNotes: $dailyNotes, images: $images, coverImagePath: $coverImagePath)';
}


}

/// @nodoc
abstract mixin class $TripFormStateCopyWith<$Res>  {
  factory $TripFormStateCopyWith(TripFormState value, $Res Function(TripFormState) _then) = _$TripFormStateCopyWithImpl;
@useResult
$Res call({
 TripModel trip, List<DailyNoteModel> dailyNotes, List<TripCommentModel> images, String? coverImagePath
});


$TripModelCopyWith<$Res> get trip;

}
/// @nodoc
class _$TripFormStateCopyWithImpl<$Res>
    implements $TripFormStateCopyWith<$Res> {
  _$TripFormStateCopyWithImpl(this._self, this._then);

  final TripFormState _self;
  final $Res Function(TripFormState) _then;

/// Create a copy of TripFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trip = null,Object? dailyNotes = null,Object? images = null,Object? coverImagePath = freezed,}) {
  return _then(_self.copyWith(
trip: null == trip ? _self.trip : trip // ignore: cast_nullable_to_non_nullable
as TripModel,dailyNotes: null == dailyNotes ? _self.dailyNotes : dailyNotes // ignore: cast_nullable_to_non_nullable
as List<DailyNoteModel>,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<TripCommentModel>,coverImagePath: freezed == coverImagePath ? _self.coverImagePath : coverImagePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TripFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TripModelCopyWith<$Res> get trip {
  
  return $TripModelCopyWith<$Res>(_self.trip, (value) {
    return _then(_self.copyWith(trip: value));
  });
}
}


/// Adds pattern-matching-related methods to [TripFormState].
extension TripFormStatePatterns on TripFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TripFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TripFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TripFormState value)  $default,){
final _that = this;
switch (_that) {
case _TripFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TripFormState value)?  $default,){
final _that = this;
switch (_that) {
case _TripFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TripModel trip,  List<DailyNoteModel> dailyNotes,  List<TripCommentModel> images,  String? coverImagePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TripFormState() when $default != null:
return $default(_that.trip,_that.dailyNotes,_that.images,_that.coverImagePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TripModel trip,  List<DailyNoteModel> dailyNotes,  List<TripCommentModel> images,  String? coverImagePath)  $default,) {final _that = this;
switch (_that) {
case _TripFormState():
return $default(_that.trip,_that.dailyNotes,_that.images,_that.coverImagePath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TripModel trip,  List<DailyNoteModel> dailyNotes,  List<TripCommentModel> images,  String? coverImagePath)?  $default,) {final _that = this;
switch (_that) {
case _TripFormState() when $default != null:
return $default(_that.trip,_that.dailyNotes,_that.images,_that.coverImagePath);case _:
  return null;

}
}

}

/// @nodoc


class _TripFormState implements TripFormState {
  const _TripFormState({required this.trip, required final  List<DailyNoteModel> dailyNotes, required final  List<TripCommentModel> images, this.coverImagePath}): _dailyNotes = dailyNotes,_images = images;
  

@override final  TripModel trip;
 final  List<DailyNoteModel> _dailyNotes;
@override List<DailyNoteModel> get dailyNotes {
  if (_dailyNotes is EqualUnmodifiableListView) return _dailyNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dailyNotes);
}

 final  List<TripCommentModel> _images;
@override List<TripCommentModel> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  String? coverImagePath;

/// Create a copy of TripFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripFormStateCopyWith<_TripFormState> get copyWith => __$TripFormStateCopyWithImpl<_TripFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TripFormState&&(identical(other.trip, trip) || other.trip == trip)&&const DeepCollectionEquality().equals(other._dailyNotes, _dailyNotes)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.coverImagePath, coverImagePath) || other.coverImagePath == coverImagePath));
}


@override
int get hashCode => Object.hash(runtimeType,trip,const DeepCollectionEquality().hash(_dailyNotes),const DeepCollectionEquality().hash(_images),coverImagePath);

@override
String toString() {
  return 'TripFormState(trip: $trip, dailyNotes: $dailyNotes, images: $images, coverImagePath: $coverImagePath)';
}


}

/// @nodoc
abstract mixin class _$TripFormStateCopyWith<$Res> implements $TripFormStateCopyWith<$Res> {
  factory _$TripFormStateCopyWith(_TripFormState value, $Res Function(_TripFormState) _then) = __$TripFormStateCopyWithImpl;
@override @useResult
$Res call({
 TripModel trip, List<DailyNoteModel> dailyNotes, List<TripCommentModel> images, String? coverImagePath
});


@override $TripModelCopyWith<$Res> get trip;

}
/// @nodoc
class __$TripFormStateCopyWithImpl<$Res>
    implements _$TripFormStateCopyWith<$Res> {
  __$TripFormStateCopyWithImpl(this._self, this._then);

  final _TripFormState _self;
  final $Res Function(_TripFormState) _then;

/// Create a copy of TripFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trip = null,Object? dailyNotes = null,Object? images = null,Object? coverImagePath = freezed,}) {
  return _then(_TripFormState(
trip: null == trip ? _self.trip : trip // ignore: cast_nullable_to_non_nullable
as TripModel,dailyNotes: null == dailyNotes ? _self._dailyNotes : dailyNotes // ignore: cast_nullable_to_non_nullable
as List<DailyNoteModel>,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<TripCommentModel>,coverImagePath: freezed == coverImagePath ? _self.coverImagePath : coverImagePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TripFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TripModelCopyWith<$Res> get trip {
  
  return $TripModelCopyWith<$Res>(_self.trip, (value) {
    return _then(_self.copyWith(trip: value));
  });
}
}

// dart format on
