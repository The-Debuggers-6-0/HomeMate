// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShoppingItem {

 String get id; String get name; String get quantity; String get addedByUid; String? get boughtByUid; bool get bought;@DateTimeConverter() DateTime get addedAt;@NullableDateTimeConverter() DateTime? get boughtAt;
/// Create a copy of ShoppingItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingItemCopyWith<ShoppingItem> get copyWith => _$ShoppingItemCopyWithImpl<ShoppingItem>(this as ShoppingItem, _$identity);

  /// Serializes this ShoppingItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.addedByUid, addedByUid) || other.addedByUid == addedByUid)&&(identical(other.boughtByUid, boughtByUid) || other.boughtByUid == boughtByUid)&&(identical(other.bought, bought) || other.bought == bought)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.boughtAt, boughtAt) || other.boughtAt == boughtAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,quantity,addedByUid,boughtByUid,bought,addedAt,boughtAt);

@override
String toString() {
  return 'ShoppingItem(id: $id, name: $name, quantity: $quantity, addedByUid: $addedByUid, boughtByUid: $boughtByUid, bought: $bought, addedAt: $addedAt, boughtAt: $boughtAt)';
}


}

/// @nodoc
abstract mixin class $ShoppingItemCopyWith<$Res>  {
  factory $ShoppingItemCopyWith(ShoppingItem value, $Res Function(ShoppingItem) _then) = _$ShoppingItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, String quantity, String addedByUid, String? boughtByUid, bool bought,@DateTimeConverter() DateTime addedAt,@NullableDateTimeConverter() DateTime? boughtAt
});




}
/// @nodoc
class _$ShoppingItemCopyWithImpl<$Res>
    implements $ShoppingItemCopyWith<$Res> {
  _$ShoppingItemCopyWithImpl(this._self, this._then);

  final ShoppingItem _self;
  final $Res Function(ShoppingItem) _then;

/// Create a copy of ShoppingItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? quantity = null,Object? addedByUid = null,Object? boughtByUid = freezed,Object? bought = null,Object? addedAt = null,Object? boughtAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,addedByUid: null == addedByUid ? _self.addedByUid : addedByUid // ignore: cast_nullable_to_non_nullable
as String,boughtByUid: freezed == boughtByUid ? _self.boughtByUid : boughtByUid // ignore: cast_nullable_to_non_nullable
as String?,bought: null == bought ? _self.bought : bought // ignore: cast_nullable_to_non_nullable
as bool,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,boughtAt: freezed == boughtAt ? _self.boughtAt : boughtAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingItem].
extension ShoppingItemPatterns on ShoppingItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingItem value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingItem value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String quantity,  String addedByUid,  String? boughtByUid,  bool bought, @DateTimeConverter()  DateTime addedAt, @NullableDateTimeConverter()  DateTime? boughtAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingItem() when $default != null:
return $default(_that.id,_that.name,_that.quantity,_that.addedByUid,_that.boughtByUid,_that.bought,_that.addedAt,_that.boughtAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String quantity,  String addedByUid,  String? boughtByUid,  bool bought, @DateTimeConverter()  DateTime addedAt, @NullableDateTimeConverter()  DateTime? boughtAt)  $default,) {final _that = this;
switch (_that) {
case _ShoppingItem():
return $default(_that.id,_that.name,_that.quantity,_that.addedByUid,_that.boughtByUid,_that.bought,_that.addedAt,_that.boughtAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String quantity,  String addedByUid,  String? boughtByUid,  bool bought, @DateTimeConverter()  DateTime addedAt, @NullableDateTimeConverter()  DateTime? boughtAt)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingItem() when $default != null:
return $default(_that.id,_that.name,_that.quantity,_that.addedByUid,_that.boughtByUid,_that.bought,_that.addedAt,_that.boughtAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShoppingItem implements ShoppingItem {
  const _ShoppingItem({this.id = '', this.name = '', this.quantity = '', this.addedByUid = '', this.boughtByUid, this.bought = false, @DateTimeConverter() required this.addedAt, @NullableDateTimeConverter() this.boughtAt});
  factory _ShoppingItem.fromJson(Map<String, dynamic> json) => _$ShoppingItemFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String quantity;
@override@JsonKey() final  String addedByUid;
@override final  String? boughtByUid;
@override@JsonKey() final  bool bought;
@override@DateTimeConverter() final  DateTime addedAt;
@override@NullableDateTimeConverter() final  DateTime? boughtAt;

/// Create a copy of ShoppingItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingItemCopyWith<_ShoppingItem> get copyWith => __$ShoppingItemCopyWithImpl<_ShoppingItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShoppingItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.addedByUid, addedByUid) || other.addedByUid == addedByUid)&&(identical(other.boughtByUid, boughtByUid) || other.boughtByUid == boughtByUid)&&(identical(other.bought, bought) || other.bought == bought)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.boughtAt, boughtAt) || other.boughtAt == boughtAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,quantity,addedByUid,boughtByUid,bought,addedAt,boughtAt);

@override
String toString() {
  return 'ShoppingItem(id: $id, name: $name, quantity: $quantity, addedByUid: $addedByUid, boughtByUid: $boughtByUid, bought: $bought, addedAt: $addedAt, boughtAt: $boughtAt)';
}


}

/// @nodoc
abstract mixin class _$ShoppingItemCopyWith<$Res> implements $ShoppingItemCopyWith<$Res> {
  factory _$ShoppingItemCopyWith(_ShoppingItem value, $Res Function(_ShoppingItem) _then) = __$ShoppingItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String quantity, String addedByUid, String? boughtByUid, bool bought,@DateTimeConverter() DateTime addedAt,@NullableDateTimeConverter() DateTime? boughtAt
});




}
/// @nodoc
class __$ShoppingItemCopyWithImpl<$Res>
    implements _$ShoppingItemCopyWith<$Res> {
  __$ShoppingItemCopyWithImpl(this._self, this._then);

  final _ShoppingItem _self;
  final $Res Function(_ShoppingItem) _then;

/// Create a copy of ShoppingItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? quantity = null,Object? addedByUid = null,Object? boughtByUid = freezed,Object? bought = null,Object? addedAt = null,Object? boughtAt = freezed,}) {
  return _then(_ShoppingItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,addedByUid: null == addedByUid ? _self.addedByUid : addedByUid // ignore: cast_nullable_to_non_nullable
as String,boughtByUid: freezed == boughtByUid ? _self.boughtByUid : boughtByUid // ignore: cast_nullable_to_non_nullable
as String?,bought: null == bought ? _self.bought : bought // ignore: cast_nullable_to_non_nullable
as bool,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,boughtAt: freezed == boughtAt ? _self.boughtAt : boughtAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
