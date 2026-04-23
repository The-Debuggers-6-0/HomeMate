// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'house.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$House {

 String get id; String get admin; String get nome; List<String> get membri;
/// Create a copy of House
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseCopyWith<House> get copyWith => _$HouseCopyWithImpl<House>(this as House, _$identity);

  /// Serializes this House to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is House&&(identical(other.id, id) || other.id == id)&&(identical(other.admin, admin) || other.admin == admin)&&(identical(other.nome, nome) || other.nome == nome)&&const DeepCollectionEquality().equals(other.membri, membri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,admin,nome,const DeepCollectionEquality().hash(membri));

@override
String toString() {
  return 'House(id: $id, admin: $admin, nome: $nome, membri: $membri)';
}


}

/// @nodoc
abstract mixin class $HouseCopyWith<$Res>  {
  factory $HouseCopyWith(House value, $Res Function(House) _then) = _$HouseCopyWithImpl;
@useResult
$Res call({
 String id, String admin, String nome, List<String> membri
});




}
/// @nodoc
class _$HouseCopyWithImpl<$Res>
    implements $HouseCopyWith<$Res> {
  _$HouseCopyWithImpl(this._self, this._then);

  final House _self;
  final $Res Function(House) _then;

/// Create a copy of House
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? admin = null,Object? nome = null,Object? membri = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,admin: null == admin ? _self.admin : admin // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,membri: null == membri ? _self.membri : membri // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [House].
extension HousePatterns on House {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _House value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _House() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _House value)  $default,){
final _that = this;
switch (_that) {
case _House():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _House value)?  $default,){
final _that = this;
switch (_that) {
case _House() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String admin,  String nome,  List<String> membri)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _House() when $default != null:
return $default(_that.id,_that.admin,_that.nome,_that.membri);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String admin,  String nome,  List<String> membri)  $default,) {final _that = this;
switch (_that) {
case _House():
return $default(_that.id,_that.admin,_that.nome,_that.membri);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String admin,  String nome,  List<String> membri)?  $default,) {final _that = this;
switch (_that) {
case _House() when $default != null:
return $default(_that.id,_that.admin,_that.nome,_that.membri);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _House implements House {
  const _House({required this.id, required this.admin, required this.nome, final  List<String> membri = const <String>[]}): _membri = membri;
  factory _House.fromJson(Map<String, dynamic> json) => _$HouseFromJson(json);

@override final  String id;
@override final  String admin;
@override final  String nome;
 final  List<String> _membri;
@override@JsonKey() List<String> get membri {
  if (_membri is EqualUnmodifiableListView) return _membri;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_membri);
}


/// Create a copy of House
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseCopyWith<_House> get copyWith => __$HouseCopyWithImpl<_House>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _House&&(identical(other.id, id) || other.id == id)&&(identical(other.admin, admin) || other.admin == admin)&&(identical(other.nome, nome) || other.nome == nome)&&const DeepCollectionEquality().equals(other._membri, _membri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,admin,nome,const DeepCollectionEquality().hash(_membri));

@override
String toString() {
  return 'House(id: $id, admin: $admin, nome: $nome, membri: $membri)';
}


}

/// @nodoc
abstract mixin class _$HouseCopyWith<$Res> implements $HouseCopyWith<$Res> {
  factory _$HouseCopyWith(_House value, $Res Function(_House) _then) = __$HouseCopyWithImpl;
@override @useResult
$Res call({
 String id, String admin, String nome, List<String> membri
});




}
/// @nodoc
class __$HouseCopyWithImpl<$Res>
    implements _$HouseCopyWith<$Res> {
  __$HouseCopyWithImpl(this._self, this._then);

  final _House _self;
  final $Res Function(_House) _then;

/// Create a copy of House
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? admin = null,Object? nome = null,Object? membri = null,}) {
  return _then(_House(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,admin: null == admin ? _self.admin : admin // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,membri: null == membri ? _self._membri : membri // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
