// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppTransaction {

 String get id; String get title; double get amount; DateTime get date; String get payerId; String get category; String get type;// 'expense' o 'reimbursement'
 String? get receiverId;// ID dell'utente che riceve il rimborso
 List<String>? get involvedUsers;// UID degli utenti tra cui è divisa
 Map<String, double>? get customShares;
/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppTransactionCopyWith<AppTransaction> get copyWith => _$AppTransactionCopyWithImpl<AppTransaction>(this as AppTransaction, _$identity);

  /// Serializes this AppTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.payerId, payerId) || other.payerId == payerId)&&(identical(other.category, category) || other.category == category)&&(identical(other.type, type) || other.type == type)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&const DeepCollectionEquality().equals(other.involvedUsers, involvedUsers)&&const DeepCollectionEquality().equals(other.customShares, customShares));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,amount,date,payerId,category,type,receiverId,const DeepCollectionEquality().hash(involvedUsers),const DeepCollectionEquality().hash(customShares));

@override
String toString() {
  return 'AppTransaction(id: $id, title: $title, amount: $amount, date: $date, payerId: $payerId, category: $category, type: $type, receiverId: $receiverId, involvedUsers: $involvedUsers, customShares: $customShares)';
}


}

/// @nodoc
abstract mixin class $AppTransactionCopyWith<$Res>  {
  factory $AppTransactionCopyWith(AppTransaction value, $Res Function(AppTransaction) _then) = _$AppTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String title, double amount, DateTime date, String payerId, String category, String type, String? receiverId, List<String>? involvedUsers, Map<String, double>? customShares
});




}
/// @nodoc
class _$AppTransactionCopyWithImpl<$Res>
    implements $AppTransactionCopyWith<$Res> {
  _$AppTransactionCopyWithImpl(this._self, this._then);

  final AppTransaction _self;
  final $Res Function(AppTransaction) _then;

/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? amount = null,Object? date = null,Object? payerId = null,Object? category = null,Object? type = null,Object? receiverId = freezed,Object? involvedUsers = freezed,Object? customShares = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,payerId: null == payerId ? _self.payerId : payerId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,receiverId: freezed == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String?,involvedUsers: freezed == involvedUsers ? _self.involvedUsers : involvedUsers // ignore: cast_nullable_to_non_nullable
as List<String>?,customShares: freezed == customShares ? _self.customShares : customShares // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppTransaction].
extension AppTransactionPatterns on AppTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppTransaction value)  $default,){
final _that = this;
switch (_that) {
case _AppTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  double amount,  DateTime date,  String payerId,  String category,  String type,  String? receiverId,  List<String>? involvedUsers,  Map<String, double>? customShares)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
return $default(_that.id,_that.title,_that.amount,_that.date,_that.payerId,_that.category,_that.type,_that.receiverId,_that.involvedUsers,_that.customShares);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  double amount,  DateTime date,  String payerId,  String category,  String type,  String? receiverId,  List<String>? involvedUsers,  Map<String, double>? customShares)  $default,) {final _that = this;
switch (_that) {
case _AppTransaction():
return $default(_that.id,_that.title,_that.amount,_that.date,_that.payerId,_that.category,_that.type,_that.receiverId,_that.involvedUsers,_that.customShares);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  double amount,  DateTime date,  String payerId,  String category,  String type,  String? receiverId,  List<String>? involvedUsers,  Map<String, double>? customShares)?  $default,) {final _that = this;
switch (_that) {
case _AppTransaction() when $default != null:
return $default(_that.id,_that.title,_that.amount,_that.date,_that.payerId,_that.category,_that.type,_that.receiverId,_that.involvedUsers,_that.customShares);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppTransaction implements AppTransaction {
  const _AppTransaction({required this.id, required this.title, required this.amount, required this.date, required this.payerId, required this.category, required this.type, this.receiverId, final  List<String>? involvedUsers, final  Map<String, double>? customShares}): _involvedUsers = involvedUsers,_customShares = customShares;
  factory _AppTransaction.fromJson(Map<String, dynamic> json) => _$AppTransactionFromJson(json);

@override final  String id;
@override final  String title;
@override final  double amount;
@override final  DateTime date;
@override final  String payerId;
@override final  String category;
@override final  String type;
// 'expense' o 'reimbursement'
@override final  String? receiverId;
// ID dell'utente che riceve il rimborso
 final  List<String>? _involvedUsers;
// ID dell'utente che riceve il rimborso
@override List<String>? get involvedUsers {
  final value = _involvedUsers;
  if (value == null) return null;
  if (_involvedUsers is EqualUnmodifiableListView) return _involvedUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// UID degli utenti tra cui è divisa
 final  Map<String, double>? _customShares;
// UID degli utenti tra cui è divisa
@override Map<String, double>? get customShares {
  final value = _customShares;
  if (value == null) return null;
  if (_customShares is EqualUnmodifiableMapView) return _customShares;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppTransactionCopyWith<_AppTransaction> get copyWith => __$AppTransactionCopyWithImpl<_AppTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.payerId, payerId) || other.payerId == payerId)&&(identical(other.category, category) || other.category == category)&&(identical(other.type, type) || other.type == type)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&const DeepCollectionEquality().equals(other._involvedUsers, _involvedUsers)&&const DeepCollectionEquality().equals(other._customShares, _customShares));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,amount,date,payerId,category,type,receiverId,const DeepCollectionEquality().hash(_involvedUsers),const DeepCollectionEquality().hash(_customShares));

@override
String toString() {
  return 'AppTransaction(id: $id, title: $title, amount: $amount, date: $date, payerId: $payerId, category: $category, type: $type, receiverId: $receiverId, involvedUsers: $involvedUsers, customShares: $customShares)';
}


}

/// @nodoc
abstract mixin class _$AppTransactionCopyWith<$Res> implements $AppTransactionCopyWith<$Res> {
  factory _$AppTransactionCopyWith(_AppTransaction value, $Res Function(_AppTransaction) _then) = __$AppTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, double amount, DateTime date, String payerId, String category, String type, String? receiverId, List<String>? involvedUsers, Map<String, double>? customShares
});




}
/// @nodoc
class __$AppTransactionCopyWithImpl<$Res>
    implements _$AppTransactionCopyWith<$Res> {
  __$AppTransactionCopyWithImpl(this._self, this._then);

  final _AppTransaction _self;
  final $Res Function(_AppTransaction) _then;

/// Create a copy of AppTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? amount = null,Object? date = null,Object? payerId = null,Object? category = null,Object? type = null,Object? receiverId = freezed,Object? involvedUsers = freezed,Object? customShares = freezed,}) {
  return _then(_AppTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,payerId: null == payerId ? _self.payerId : payerId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,receiverId: freezed == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String?,involvedUsers: freezed == involvedUsers ? _self._involvedUsers : involvedUsers // ignore: cast_nullable_to_non_nullable
as List<String>?,customShares: freezed == customShares ? _self._customShares : customShares // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,
  ));
}


}

// dart format on
