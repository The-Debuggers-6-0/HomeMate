// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cleaning_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CleaningTask {

 String get id; String get title; String get assigneeUid;@DateTimeConverter() DateTime get weekStart;// settimana di riferimento
 bool get completed;@NullableDateTimeConverter() DateTime? get completedAt;
/// Create a copy of CleaningTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CleaningTaskCopyWith<CleaningTask> get copyWith => _$CleaningTaskCopyWithImpl<CleaningTask>(this as CleaningTask, _$identity);

  /// Serializes this CleaningTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CleaningTask&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.assigneeUid, assigneeUid) || other.assigneeUid == assigneeUid)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,assigneeUid,weekStart,completed,completedAt);

@override
String toString() {
  return 'CleaningTask(id: $id, title: $title, assigneeUid: $assigneeUid, weekStart: $weekStart, completed: $completed, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $CleaningTaskCopyWith<$Res>  {
  factory $CleaningTaskCopyWith(CleaningTask value, $Res Function(CleaningTask) _then) = _$CleaningTaskCopyWithImpl;
@useResult
$Res call({
 String id, String title, String assigneeUid,@DateTimeConverter() DateTime weekStart, bool completed,@NullableDateTimeConverter() DateTime? completedAt
});




}
/// @nodoc
class _$CleaningTaskCopyWithImpl<$Res>
    implements $CleaningTaskCopyWith<$Res> {
  _$CleaningTaskCopyWithImpl(this._self, this._then);

  final CleaningTask _self;
  final $Res Function(CleaningTask) _then;

/// Create a copy of CleaningTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? assigneeUid = null,Object? weekStart = null,Object? completed = null,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,assigneeUid: null == assigneeUid ? _self.assigneeUid : assigneeUid // ignore: cast_nullable_to_non_nullable
as String,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as DateTime,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CleaningTask].
extension CleaningTaskPatterns on CleaningTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CleaningTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CleaningTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CleaningTask value)  $default,){
final _that = this;
switch (_that) {
case _CleaningTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CleaningTask value)?  $default,){
final _that = this;
switch (_that) {
case _CleaningTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String assigneeUid, @DateTimeConverter()  DateTime weekStart,  bool completed, @NullableDateTimeConverter()  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CleaningTask() when $default != null:
return $default(_that.id,_that.title,_that.assigneeUid,_that.weekStart,_that.completed,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String assigneeUid, @DateTimeConverter()  DateTime weekStart,  bool completed, @NullableDateTimeConverter()  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _CleaningTask():
return $default(_that.id,_that.title,_that.assigneeUid,_that.weekStart,_that.completed,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String assigneeUid, @DateTimeConverter()  DateTime weekStart,  bool completed, @NullableDateTimeConverter()  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _CleaningTask() when $default != null:
return $default(_that.id,_that.title,_that.assigneeUid,_that.weekStart,_that.completed,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CleaningTask implements CleaningTask {
  const _CleaningTask({this.id = '', this.title = '', this.assigneeUid = '', @DateTimeConverter() required this.weekStart, this.completed = false, @NullableDateTimeConverter() this.completedAt});
  factory _CleaningTask.fromJson(Map<String, dynamic> json) => _$CleaningTaskFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String assigneeUid;
@override@DateTimeConverter() final  DateTime weekStart;
// settimana di riferimento
@override@JsonKey() final  bool completed;
@override@NullableDateTimeConverter() final  DateTime? completedAt;

/// Create a copy of CleaningTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CleaningTaskCopyWith<_CleaningTask> get copyWith => __$CleaningTaskCopyWithImpl<_CleaningTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CleaningTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CleaningTask&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.assigneeUid, assigneeUid) || other.assigneeUid == assigneeUid)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,assigneeUid,weekStart,completed,completedAt);

@override
String toString() {
  return 'CleaningTask(id: $id, title: $title, assigneeUid: $assigneeUid, weekStart: $weekStart, completed: $completed, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$CleaningTaskCopyWith<$Res> implements $CleaningTaskCopyWith<$Res> {
  factory _$CleaningTaskCopyWith(_CleaningTask value, $Res Function(_CleaningTask) _then) = __$CleaningTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String assigneeUid,@DateTimeConverter() DateTime weekStart, bool completed,@NullableDateTimeConverter() DateTime? completedAt
});




}
/// @nodoc
class __$CleaningTaskCopyWithImpl<$Res>
    implements _$CleaningTaskCopyWith<$Res> {
  __$CleaningTaskCopyWithImpl(this._self, this._then);

  final _CleaningTask _self;
  final $Res Function(_CleaningTask) _then;

/// Create a copy of CleaningTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? assigneeUid = null,Object? weekStart = null,Object? completed = null,Object? completedAt = freezed,}) {
  return _then(_CleaningTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,assigneeUid: null == assigneeUid ? _self.assigneeUid : assigneeUid // ignore: cast_nullable_to_non_nullable
as String,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as DateTime,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
