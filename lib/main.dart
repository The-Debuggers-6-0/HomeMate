import 'package:flutter/material.dart';
import 'schermate/home_screen.dart';
import 'theme/app_colors.dart';
import 'schermate/finanze_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HomeMate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      // Impostiamo la nostra nuova HomeScreen come pagina principale
      home: const HomeScreen(),
    );
  }
}
