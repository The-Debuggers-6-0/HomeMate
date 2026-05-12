import 'package:flutter/material.dart';
import '../../../domain/models/app_user.dart';
import 'user_avatar.dart';
import 'roommate_profile_sheet.dart';

class ClickableUserAvatar extends StatelessWidget {
  final AppUser user;
  final double radius;

  const ClickableUserAvatar({
    super.key,
    required this.user,
    this.radius = 26,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 💥 Apre automaticamente il profilo!
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => RoommateProfileSheet(user: user),
        );
      },
      child: UserAvatar(user: user, radius: radius),
    );
  }
}