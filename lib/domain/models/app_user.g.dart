// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  uid: json['uid'] as String,
  email: json['email'] as String,
  name: json['name'] as String? ?? '',
  surname: json['surname'] as String? ?? '',
  bio: json['bio'] as String? ?? '',
  profileCompleted: json['profileCompleted'] as bool? ?? false,
  homeId: json['homeId'] as String? ?? '',
  photoUrl: json['photoUrl'] as String?,
  unlockedBadges:
      (json['unlockedBadges'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, UserBadge.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  featuredBadges:
      (json['featuredBadges'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'name': instance.name,
  'surname': instance.surname,
  'bio': instance.bio,
  'profileCompleted': instance.profileCompleted,
  'homeId': instance.homeId,
  'photoUrl': instance.photoUrl,
  'unlockedBadges': instance.unlockedBadges,
  'featuredBadges': instance.featuredBadges,
};
