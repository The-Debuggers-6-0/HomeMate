import 'package:flutter/material.dart';

class BadgeIconHelper {
  // Funzione statica, così possiamo usarla ovunque senza creare oggetti
  static IconData getIconFromName(String? iconName) {
    switch (iconName) {
      case 'local_fire_department': return Icons.local_fire_department;
      case 'cleaning_services': return Icons.cleaning_services;
      case 'bolt': return Icons.bolt;
      case 'celebration': return Icons.celebration;
      case 'recycling': return Icons.recycling;
      case 'wb_sunny': return Icons.wb_sunny;
      case 'water_drop': return Icons.water_drop;
      case 'eco': return Icons.eco;
      case 'attach_money': return Icons.attach_money;
      case 'description': return Icons.description; 
      case 'park': return Icons.park;            
      case 'local_drink': return Icons.local_drink; 
      case 'compost': return Icons.compost;
      case 'wine_bar': return Icons.wine_bar;
      case 'delete_outline': return Icons.delete_outline;
      default: return Icons.emoji_events; // Icona trofeo di default
    }
  }
}