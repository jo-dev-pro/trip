// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_detail_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TripDetailState {

 TripModel get trip; List<TripCommentModel> get comments; List<DailyNoteModel> get dailyNotes;
/// Create a copy of TripDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripDetailStateCopyWith<TripDetailState> get copyWith => _$TripDetailStateCopyWithImpl<TripDetailState>(this as TripDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TripDetailState&&(identical(other.trip, trip) || other.trip == trip)&&const DeepCollectionEquality().equals(other.comments, comments)&&const DeepCollectionEquality().equals(other.dailyNotes, dailyNotes));
}


@override
int get hashCode => Object.hash(runtimeType,trip,const DeepCollectionEquality().hash(comments),const DeepCollectionEquality().hash(dailyNotes));

@override
String toString() {
  return 'TripDetailState(trip: $trip, comments: $comments, dailyNotes: $dailyNotes)';
}


}

/// @nodoc
abstract mixin class $TripDetailStateCopyWith<$Res>  {
  factory $TripDetailStateCopyWith(TripDetailState value, $Res Function(TripDetailState) _then) = _$TripDetailStateCopyWithImpl;
@useResult
$Res call({
 TripModel trip, List<TripCommentModel> comments, List<DailyNoteModel> dailyNotes
});


$TripModelCopyWith<$Res> get trip;

}
/// @nodoc
class _$TripDetailStateCopyWithImpl<$Res>
    implements $TripDetailStateCopyWith<$Res> {
  _$TripDetailStateCopyWithImpl(this._self, this._then);

  final TripDetailState _self;
  final $Res Function(TripDetailState) _then;

/// Create a copy of TripDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trip = null,Object? comments = null,Object? dailyNotes = null,}) {
  return _then(_self.copyWith(
trip: null == trip ? _self.trip : trip // ignore: cast_nullable_to_non_nullable
as TripModel,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<TripCommentModel>,dailyNotes: null == dailyNotes ? _self.dailyNotes : dailyNotes // ignore: cast_nullable_to_non_nullable
as List<DailyNoteModel>,
  ));
}
/// Create a copy of TripDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TripModelCopyWith<$Res> get trip {
  
  return $TripModelCopyWith<$Res>(_self.trip, (value) {
    return _then(_self.copyWith(trip: value));
  });
}
}


/// Adds pattern-matching-related methods to [TripDetailState].
extension TripDetailStatePatterns on TripDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TripDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TripDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TripDetailState value)  $default,){
final _that = this;
switch (_that) {
case _TripDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TripDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _TripDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TripModel trip,  List<TripCommentModel> comments,  List<DailyNoteModel> dailyNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TripDetailState() when $default != null:
return $default(_that.trip,_that.comments,_that.dailyNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TripModel trip,  List<TripCommentModel> comments,  List<DailyNoteModel> dailyNotes)  $default,) {final _that = this;
switch (_that) {
case _TripDetailState():
return $default(_that.trip,_that.comments,_that.dailyNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TripModel trip,  List<TripCommentModel> comments,  List<DailyNoteModel> dailyNotes)?  $default,) {final _that = this;
switch (_that) {
case _TripDetailState() when $default != null:
return $default(_that.trip,_that.comments,_that.dailyNotes);case _:
  return null;

}
}

}

/// @nodoc


class _TripDetailState implements TripDetailState {
  const _TripDetailState({required this.trip, required final  List<TripCommentModel> comments, required final  List<DailyNoteModel> dailyNotes}): _comments = comments,_dailyNotes = dailyNotes;
  

@override final  TripModel trip;
 final  List<TripCommentModel> _comments;
@override List<TripCommentModel> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}

 final  List<DailyNoteModel> _dailyNotes;
@override List<DailyNoteModel> get dailyNotes {
  if (_dailyNotes is EqualUnmodifiableListView) return _dailyNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dailyNotes);
}


/// Create a copy of TripDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripDetailStateCopyWith<_TripDetailState> get copyWith => __$TripDetailStateCopyWithImpl<_TripDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TripDetailState&&(identical(other.trip, trip) || other.trip == trip)&&const DeepCollectionEquality().equals(other._comments, _comments)&&const DeepCollectionEquality().equals(other._dailyNotes, _dailyNotes));
}


@override
int get hashCode => Object.hash(runtimeType,trip,const DeepCollectionEquality().hash(_comments),const DeepCollectionEquality().hash(_dailyNotes));

@override
String toString() {
  return 'TripDetailState(trip: $trip, comments: $comments, dailyNotes: $dailyNotes)';
}


}

/// @nodoc
abstract mixin class _$TripDetailStateCopyWith<$Res> implements $TripDetailStateCopyWith<$Res> {
  factory _$TripDetailStateCopyWith(_TripDetailState value, $Res Function(_TripDetailState) _then) = __$TripDetailStateCopyWithImpl;
@override @useResult
$Res call({
 TripModel trip, List<TripCommentModel> comments, List<DailyNoteModel> dailyNotes
});


@override $TripModelCopyWith<$Res> get trip;

}
/// @nodoc
class __$TripDetailStateCopyWithImpl<$Res>
    implements _$TripDetailStateCopyWith<$Res> {
  __$TripDetailStateCopyWithImpl(this._self, this._then);

  final _TripDetailState _self;
  final $Res Function(_TripDetailState) _then;

/// Create a copy of TripDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trip = null,Object? comments = null,Object? dailyNotes = null,}) {
  return _then(_TripDetailState(
trip: null == trip ? _self.trip : trip // ignore: cast_nullable_to_non_nullable
as TripModel,comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<TripCommentModel>,dailyNotes: null == dailyNotes ? _self._dailyNotes : dailyNotes // ignore: cast_nullable_to_non_nullable
as List<DailyNoteModel>,
  ));
}

/// Create a copy of TripDetailState
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
