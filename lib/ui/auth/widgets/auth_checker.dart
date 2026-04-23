import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/auth_view_model.dart';
import '../../core/ui/loading_overlay.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';
import '../../setup_profile/widgets/setup_profile_screen.dart';
import '../../house/widgets/add_house_screen.dart';
import '../../main_layout/widgets/main_layout.dart';

/// Widget radice che osserva [AuthViewModel] e mostra la schermata
/// corretta in base allo stato di autenticazione [AuthStatus].
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    if (authViewModel.isLoading) {
      return const LoadingOverlay();
    }

    switch (authViewModel.status) {
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.emailNotVerified:
        return const VerifyEmailScreen();
      case AuthStatus.profileIncomplete:
        return const SetupProfileScreen();
      case AuthStatus.noHouse:
        return const AddHouseScreen();
      case AuthStatus.authenticated:
        return const MainLayout();
      case AuthStatus.unknown:
        return const LoadingOverlay();
    }
  }
}
