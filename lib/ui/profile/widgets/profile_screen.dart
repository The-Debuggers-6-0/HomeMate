import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/profile_view_model.dart';

/// Schermata Profilo. View pura che legge i dati da [ProfileViewModel].
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    final Color darkGreen = const Color(0xFF2C5542);
    final Color textColor = const Color(0xFF1E1E1E);
    final Color subtitleColor = const Color(0xFF5A5A5A);

    if (viewModel.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAF9),
        body: Center(child: CircularProgressIndicator(color: darkGreen)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // --- HEADER: Ciao, Nome ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(Icons.person,
                            size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Ciao, ${viewModel.displayName}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: darkGreen,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.notifications_none, color: subtitleColor),
                ],
              ),
              const SizedBox(height: 48),

              // --- FOTO PROFILO CENTRALE ---
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: darkGreen.withOpacity(0.8), width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person,
                          size: 50, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: darkGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFF9FAF9), width: 2),
                    ),
                    child: const Icon(Icons.edit,
                        size: 14, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- NOME E COGNOME ---
              Text(
                viewModel.fullName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),

              // --- BIO / EMAIL ---
              Text(
                viewModel.bio,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                ),
              ),

              const Spacer(),

              // --- PULSANTE LOGOUT ---
              TextButton.icon(
                onPressed: () => viewModel.logout(),
                icon: const Icon(Icons.logout, color: Color(0xFFC62828)),
                label: const Text(
                  "Disconnetti Account",
                  style: TextStyle(
                    color: Color(0xFFC62828),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
