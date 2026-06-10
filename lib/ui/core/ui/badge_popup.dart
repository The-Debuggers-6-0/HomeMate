import 'package:flutter/material.dart';
import '../../core/ui/badge_icon_helper.dart';

void showGenericBadgePopup(BuildContext context, Map<String, dynamic> badgeMeta) {
  final String title = badgeMeta['title'] ?? "Traguardo!";
  final String desc = badgeMeta['description'] ?? "";
  final String hexColor = badgeMeta['color'] ?? "#FFC107";
  final Color color = Color(int.parse(hexColor.replaceFirst('#', '0xff'))); 

  final iconData = BadgeIconHelper.getIconFromName(badgeMeta['iconName']);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(iconData, size: 60, color: color),
              ),
              const SizedBox(height: 24),
              const Text(
                "NUOVO TRAGUARDO!",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Fantastico!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      );
    }
  );
}