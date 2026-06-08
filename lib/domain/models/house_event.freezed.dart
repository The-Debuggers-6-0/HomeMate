// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'house_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HouseEvent {

 String get id; String get title;@DateTimeConverter() DateTime get start;@NullableDateTimeConverter() DateTime? get end; String get creatorUid; String? get notes;
/// Create a copy of HouseEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseEventCopyWith<HouseEvent> get copyWith => _$HouseEventCopyWithImpl<HouseEvent>(this as HouseEvent, _$identity);

  /// Serializes this HouseEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.creatorUid, creatorUid) || other.creatorUid == creatorUid)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,start,end,creatorUid,notes);

@override
String toString() {
  return 'HouseEvent(id: $id, title: $title, start: $start, end: $end, creatorUid: $creatorUid, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $HouseEventCopyWith<$Res>  {
  factory $HouseEventCopyWith(HouseEvent value, $Res Function(HouseEvent) _then) = _$HouseEventCopyWithImpl;
@useResult
$Res call({
 String id, String title,@DateTimeConverter() DateTime start,@NullableDateTimeConverter() DateTime? end, String creatorUid, String? notes
});




}
/// @nodoc
class _$HouseEventCopyWithImpl<$Res>
    implements $HouseEventCopyWith<$Res> {
  _$HouseEventCopyWithImpl(this._self, this._then);

  final HouseEvent _self;
  final $Res Function(HouseEvent) _then;

/// Create a copy of HouseEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? start = null,Object? end = freezed,Object? creatorUid = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime?,creatorUid: null == creatorUid ? _self.creatorUid : creatorUid // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseEvent].
extension HouseEventPatterns on HouseEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseEvent value)  $default,){
final _that = this;
switch (_that) {
case _HouseEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseEvent value)?  $default,){
final _that = this;
switch (_that) {
case _HouseEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title, @DateTimeConverter()  DateTime start, @NullableDateTimeConverter()  DateTime? end,  String creatorUid,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseEvent() when $default != null:
return $default(_that.id,_that.title,_that.start,_that.end,_that.creatorUid,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title, @DateTimeConverter()  DateTime start, @NullableDateTimeConverter()  DateTime? end,  String creatorUid,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _HouseEvent():
return $default(_that.id,_that.title,_that.start,_that.end,_that.creatorUid,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title, @DateTimeConverter()  DateTime start, @NullableDateTimeConverter()  DateTime? end,  String creatorUid,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _HouseEvent() when $default != null:
return $default(_that.id,_that.title,_that.start,_that.end,_that.creatorUid,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseEvent implements HouseEvent {
  const _HouseEvent({this.id = '', this.title = '', @DateTimeConverter() required this.start, @NullableDateTimeConverter() this.end, this.creatorUid = '', this.notes});
  factory _HouseEvent.fromJson(Map<String, dynamic> json) => _$HouseEventFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String title;
@override@DateTimeConverter() final  DateTime start;
@override@NullableDateTimeConverter() final  DateTime? end;
@override@JsonKey() final  String creatorUid;
@override final  String? notes;

/// Create a copy of HouseEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseEventCopyWith<_HouseEvent> get copyWith => __$HouseEventCopyWithImpl<_HouseEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.creatorUid, creatorUid) || other.creatorUid == creatorUid)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,start,end,creatorUid,notes);

@override
String toString() {
  return 'HouseEvent(id: $id, title: $title, start: $start, end: $end, creatorUid: $creatorUid, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$HouseEventCopyWith<$Res> implements $HouseEventCopyWith<$Res> {
  factory _$HouseEventCopyWith(_HouseEvent value, $Res Function(_HouseEvent) _then) = __$HouseEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title,@DateTimeConverter() DateTime start,@NullableDateTimeConverter() DateTime? end, String creatorUid, String? notes
});




}
/// @nodoc
class __$HouseEventCopyWithImpl<$Res>
    implements _$HouseEventCopyWith<$Res> {
  __$HouseEventCopyWithImpl(this._self, this._then);

  final _HouseEvent _self;
  final $Res Function(_HouseEvent) _then;

/// Create a copy of HouseEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? start = null,Object? end = freezed,Object? creatorUid = null,Object? notes = freezed,}) {
  return _then(_HouseEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime?,creatorUid: null == creatorUid ? _self.creatorUid : creatorUid // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
