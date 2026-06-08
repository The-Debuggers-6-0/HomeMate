// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'house_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HouseRule {

 String get id; String get title; String get description;
/// Create a copy of HouseRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseRuleCopyWith<HouseRule> get copyWith => _$HouseRuleCopyWithImpl<HouseRule>(this as HouseRule, _$identity);

  /// Serializes this HouseRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseRule&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description);

@override
String toString() {
  return 'HouseRule(id: $id, title: $title, description: $description)';
}


}

/// @nodoc
abstract mixin class $HouseRuleCopyWith<$Res>  {
  factory $HouseRuleCopyWith(HouseRule value, $Res Function(HouseRule) _then) = _$HouseRuleCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description
});




}
/// @nodoc
class _$HouseRuleCopyWithImpl<$Res>
    implements $HouseRuleCopyWith<$Res> {
  _$HouseRuleCopyWithImpl(this._self, this._then);

  final HouseRule _self;
  final $Res Function(HouseRule) _then;

/// Create a copy of HouseRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseRule].
extension HouseRulePatterns on HouseRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseRule value)  $default,){
final _that = this;
switch (_that) {
case _HouseRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseRule value)?  $default,){
final _that = this;
switch (_that) {
case _HouseRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseRule() when $default != null:
return $default(_that.id,_that.title,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description)  $default,) {final _that = this;
switch (_that) {
case _HouseRule():
return $default(_that.id,_that.title,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description)?  $default,) {final _that = this;
switch (_that) {
case _HouseRule() when $default != null:
return $default(_that.id,_that.title,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseRule implements HouseRule {
  const _HouseRule({this.id = '', this.title = '', this.description = ''});
  factory _HouseRule.fromJson(Map<String, dynamic> json) => _$HouseRuleFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;

/// Create a copy of HouseRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseRuleCopyWith<_HouseRule> get copyWith => __$HouseRuleCopyWithImpl<_HouseRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseRule&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description);

@override
String toString() {
  return 'HouseRule(id: $id, title: $title, description: $description)';
}


}

/// @nodoc
abstract mixin class _$HouseRuleCopyWith<$Res> implements $HouseRuleCopyWith<$Res> {
  factory _$HouseRuleCopyWith(_HouseRule value, $Res Function(_HouseRule) _then) = __$HouseRuleCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description
});




}
/// @nodoc
class __$HouseRuleCopyWithImpl<$Res>
    implements _$HouseRuleCopyWith<$Res> {
  __$HouseRuleCopyWithImpl(this._self, this._then);

  final _HouseRule _self;
  final $Res Function(_HouseRule) _then;

/// Create a copy of HouseRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,}) {
  return _then(_HouseRule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
