// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sticky_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StickyNote {

 String get id; String get content; String get authorUid; String get authorName; String get authorPhotoUrl;@DateTimeConverter() DateTime get createdAt;
/// Create a copy of StickyNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StickyNoteCopyWith<StickyNote> get copyWith => _$StickyNoteCopyWithImpl<StickyNote>(this as StickyNote, _$identity);

  /// Serializes this StickyNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StickyNote&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.authorUid, authorUid) || other.authorUid == authorUid)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorPhotoUrl, authorPhotoUrl) || other.authorPhotoUrl == authorPhotoUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,authorUid,authorName,authorPhotoUrl,createdAt);

@override
String toString() {
  return 'StickyNote(id: $id, content: $content, authorUid: $authorUid, authorName: $authorName, authorPhotoUrl: $authorPhotoUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $StickyNoteCopyWith<$Res>  {
  factory $StickyNoteCopyWith(StickyNote value, $Res Function(StickyNote) _then) = _$StickyNoteCopyWithImpl;
@useResult
$Res call({
 String id, String content, String authorUid, String authorName, String authorPhotoUrl,@DateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$StickyNoteCopyWithImpl<$Res>
    implements $StickyNoteCopyWith<$Res> {
  _$StickyNoteCopyWithImpl(this._self, this._then);

  final StickyNote _self;
  final $Res Function(StickyNote) _then;

/// Create a copy of StickyNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? authorUid = null,Object? authorName = null,Object? authorPhotoUrl = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,authorUid: null == authorUid ? _self.authorUid : authorUid // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorPhotoUrl: null == authorPhotoUrl ? _self.authorPhotoUrl : authorPhotoUrl // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StickyNote].
extension StickyNotePatterns on StickyNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StickyNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StickyNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StickyNote value)  $default,){
final _that = this;
switch (_that) {
case _StickyNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StickyNote value)?  $default,){
final _that = this;
switch (_that) {
case _StickyNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  String authorUid,  String authorName,  String authorPhotoUrl, @DateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StickyNote() when $default != null:
return $default(_that.id,_that.content,_that.authorUid,_that.authorName,_that.authorPhotoUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  String authorUid,  String authorName,  String authorPhotoUrl, @DateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _StickyNote():
return $default(_that.id,_that.content,_that.authorUid,_that.authorName,_that.authorPhotoUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  String authorUid,  String authorName,  String authorPhotoUrl, @DateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _StickyNote() when $default != null:
return $default(_that.id,_that.content,_that.authorUid,_that.authorName,_that.authorPhotoUrl,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StickyNote implements StickyNote {
  const _StickyNote({this.id = '', this.content = '', this.authorUid = '', this.authorName = '', this.authorPhotoUrl = '', @DateTimeConverter() required this.createdAt});
  factory _StickyNote.fromJson(Map<String, dynamic> json) => _$StickyNoteFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String content;
@override@JsonKey() final  String authorUid;
@override@JsonKey() final  String authorName;
@override@JsonKey() final  String authorPhotoUrl;
@override@DateTimeConverter() final  DateTime createdAt;

/// Create a copy of StickyNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StickyNoteCopyWith<_StickyNote> get copyWith => __$StickyNoteCopyWithImpl<_StickyNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StickyNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StickyNote&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.authorUid, authorUid) || other.authorUid == authorUid)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorPhotoUrl, authorPhotoUrl) || other.authorPhotoUrl == authorPhotoUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,authorUid,authorName,authorPhotoUrl,createdAt);

@override
String toString() {
  return 'StickyNote(id: $id, content: $content, authorUid: $authorUid, authorName: $authorName, authorPhotoUrl: $authorPhotoUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$StickyNoteCopyWith<$Res> implements $StickyNoteCopyWith<$Res> {
  factory _$StickyNoteCopyWith(_StickyNote value, $Res Function(_StickyNote) _then) = __$StickyNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, String authorUid, String authorName, String authorPhotoUrl,@DateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$StickyNoteCopyWithImpl<$Res>
    implements _$StickyNoteCopyWith<$Res> {
  __$StickyNoteCopyWithImpl(this._self, this._then);

  final _StickyNote _self;
  final $Res Function(_StickyNote) _then;

/// Create a copy of StickyNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? authorUid = null,Object? authorName = null,Object? authorPhotoUrl = null,Object? createdAt = null,}) {
  return _then(_StickyNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,authorUid: null == authorUid ? _self.authorUid : authorUid // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorPhotoUrl: null == authorPhotoUrl ? _self.authorPhotoUrl : authorPhotoUrl // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
