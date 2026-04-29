import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/db_service.dart';

void main() async {
  // Setup Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // IMPORTANT: The user must run `flutterfire configure` to generate firebase_options.dart.
  // Until then, Firebase.initializeApp() will look for native platform configs.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase not configured: \$e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => DatabaseService()),
      ],
      child: const RealEstateApp(),
    ),
  );
}

class RealEstateApp extends StatelessWidget {
  const RealEstateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Estate App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
