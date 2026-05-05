import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../domain/models/app_user.dart';
import '../themes/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final AppUser? user;
  final String? photoUrl; // Permette di passare direttamente la stringa se l'AppUser non è disponibile
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;

  const UserAvatar({
    super.key,
    this.user,
    this.photoUrl,
    this.radius = 20,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final String? effectivePhotoUrl = photoUrl ?? user?.photoUrl;
    ImageProvider? imageProvider;

    if (effectivePhotoUrl != null && effectivePhotoUrl.isNotEmpty) {
      try {
        if (effectivePhotoUrl.startsWith('http')) {
          imageProvider = NetworkImage(effectivePhotoUrl);
        } else {
          // Assume base64, handle potential data:image/... prefix
          final base64String = effectivePhotoUrl.contains(',') 
              ? effectivePhotoUrl.split(',').last 
              : effectivePhotoUrl;
          imageProvider = MemoryImage(base64Decode(base64String));
        }
      } catch (e) {
        debugPrint('Error decoding avatar image: $e');
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[300],
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Text(
              user?.name.isNotEmpty == true 
                  ? user!.name[0].toUpperCase() 
                  : (user?.email.isNotEmpty == true ? user!.email[0].toUpperCase() : '?'),
              style: TextStyle(
                color: iconColor ?? AppColors.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }
}
