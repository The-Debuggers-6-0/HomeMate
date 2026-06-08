// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_badge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserBadge {

 String get templateId;@DateTimeConverter() DateTime get unlockedAt; int? get month; int? get year;
/// Create a copy of UserBadge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserBadgeCopyWith<UserBadge> get copyWith => _$UserBadgeCopyWithImpl<UserBadge>(this as UserBadge, _$identity);

  /// Serializes this UserBadge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserBadge&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,templateId,unlockedAt,month,year);

@override
String toString() {
  return 'UserBadge(templateId: $templateId, unlockedAt: $unlockedAt, month: $month, year: $year)';
}


}

/// @nodoc
abstract mixin class $UserBadgeCopyWith<$Res>  {
  factory $UserBadgeCopyWith(UserBadge value, $Res Function(UserBadge) _then) = _$UserBadgeCopyWithImpl;
@useResult
$Res call({
 String templateId,@DateTimeConverter() DateTime unlockedAt, int? month, int? year
});




}
/// @nodoc
class _$UserBadgeCopyWithImpl<$Res>
    implements $UserBadgeCopyWith<$Res> {
  _$UserBadgeCopyWithImpl(this._self, this._then);

  final UserBadge _self;
  final $Res Function(UserBadge) _then;

/// Create a copy of UserBadge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? templateId = null,Object? unlockedAt = null,Object? month = freezed,Object? year = freezed,}) {
  return _then(_self.copyWith(
templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,unlockedAt: null == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime,month: freezed == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserBadge].
extension UserBadgePatterns on UserBadge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserBadge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserBadge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserBadge value)  $default,){
final _that = this;
switch (_that) {
case _UserBadge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserBadge value)?  $default,){
final _that = this;
switch (_that) {
case _UserBadge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String templateId, @DateTimeConverter()  DateTime unlockedAt,  int? month,  int? year)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserBadge() when $default != null:
return $default(_that.templateId,_that.unlockedAt,_that.month,_that.year);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String templateId, @DateTimeConverter()  DateTime unlockedAt,  int? month,  int? year)  $default,) {final _that = this;
switch (_that) {
case _UserBadge():
return $default(_that.templateId,_that.unlockedAt,_that.month,_that.year);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String templateId, @DateTimeConverter()  DateTime unlockedAt,  int? month,  int? year)?  $default,) {final _that = this;
switch (_that) {
case _UserBadge() when $default != null:
return $default(_that.templateId,_that.unlockedAt,_that.month,_that.year);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserBadge implements UserBadge {
  const _UserBadge({this.templateId = '', @DateTimeConverter() required this.unlockedAt, this.month, this.year});
  factory _UserBadge.fromJson(Map<String, dynamic> json) => _$UserBadgeFromJson(json);

@override@JsonKey() final  String templateId;
@override@DateTimeConverter() final  DateTime unlockedAt;
@override final  int? month;
@override final  int? year;

/// Create a copy of UserBadge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserBadgeCopyWith<_UserBadge> get copyWith => __$UserBadgeCopyWithImpl<_UserBadge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserBadgeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserBadge&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,templateId,unlockedAt,month,year);

@override
String toString() {
  return 'UserBadge(templateId: $templateId, unlockedAt: $unlockedAt, month: $month, year: $year)';
}


}

/// @nodoc
abstract mixin class _$UserBadgeCopyWith<$Res> implements $UserBadgeCopyWith<$Res> {
  factory _$UserBadgeCopyWith(_UserBadge value, $Res Function(_UserBadge) _then) = __$UserBadgeCopyWithImpl;
@override @useResult
$Res call({
 String templateId,@DateTimeConverter() DateTime unlockedAt, int? month, int? year
});




}
/// @nodoc
class __$UserBadgeCopyWithImpl<$Res>
    implements _$UserBadgeCopyWith<$Res> {
  __$UserBadgeCopyWithImpl(this._self, this._then);

  final _UserBadge _self;
  final $Res Function(_UserBadge) _then;

/// Create a copy of UserBadge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? templateId = null,Object? unlockedAt = null,Object? month = freezed,Object? year = freezed,}) {
  return _then(_UserBadge(
templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,unlockedAt: null == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime,month: freezed == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
