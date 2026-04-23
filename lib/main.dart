import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// --- Data Layer: Services ---
import 'data/services/auth_service.dart';
import 'data/services/user_service.dart';
import 'data/services/house_service.dart';

// --- Data Layer: Repositories ---
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/house_repository.dart';

// --- UI Layer: ViewModels ---
import 'ui/auth/view_model/auth_view_model.dart';
import 'ui/auth/view_model/login_view_model.dart';
import 'ui/auth/view_model/register_view_model.dart';
import 'ui/auth/view_model/forgot_password_view_model.dart';
import 'ui/setup_profile/view_model/setup_profile_view_model.dart';
import 'ui/house/view_model/house_view_model.dart';
import 'ui/home/view_model/home_view_model.dart';
import 'ui/finanze/view_model/finanze_view_model.dart';
import 'ui/profile/view_model/profile_view_model.dart';
import 'ui/profile/view_model/edit_profile_view_model.dart';

// --- UI Layer: Root Widget ---
import 'ui/auth/widgets/auth_checker.dart';
import 'ui/core/themes/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- Inizializzazione Services (singleton) ---
  final authService = AuthService();
  final userService = UserService();
  final houseService = HouseService();

  // --- Inizializzazione Repositories (ricevono i service come dipendenza) ---
  final authRepository = AuthRepository(
    authService: authService,
    userService: userService,
  );
  final userRepository = UserRepository(userService: userService);
  final houseRepository = HouseRepository(
    houseService: houseService,
    userService: userService,
  );

  runApp(MyApp(
    authRepository: authRepository,
    userRepository: userRepository,
    houseRepository: houseRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final HouseRepository houseRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.userRepository,
    required this.houseRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- Repository Providers (accessibili ovunque) ---
        Provider<AuthRepository>.value(value: authRepository),
        Provider<UserRepository>.value(value: userRepository),
        Provider<HouseRepository>.value(value: houseRepository),

        // --- ViewModel Providers ---
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(
            authRepository: authRepository,
            userRepository: userRepository,
          ),
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (_) => LoginViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider<RegisterViewModel>(
          create: (_) => RegisterViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider<ForgotPasswordViewModel>(
          create: (_) =>
              ForgotPasswordViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider<SetupProfileViewModel>(
          create: (_) => SetupProfileViewModel(
            userRepository: userRepository,
            authRepository: authRepository,
          ),
        ),
        ChangeNotifierProvider<HouseViewModel>(
          create: (_) => HouseViewModel(
            houseRepository: houseRepository,
            authRepository: authRepository,
          ),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => HomeViewModel(),
        ),
        ChangeNotifierProvider<FinanzeViewModel>(
          create: (_) => FinanzeViewModel(),
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => ProfileViewModel(
            userRepository: userRepository,
            authRepository: authRepository,
          ),
        ),
        ChangeNotifierProvider<EditProfileViewModel>(
          create: (_) => EditProfileViewModel(
            userRepository: userRepository, // Gli passiamo il repository che abbiamo già creato nel main!
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HomeMate',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
        ),
        home: const AuthChecker(),
      ),
    );
  }
}
