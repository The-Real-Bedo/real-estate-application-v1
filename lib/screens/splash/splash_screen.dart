import 'package:flutter/material.dart';
import 'package:real_estate_app/screens/auth/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main_layout.dart';
import '../admin/admin_dashboard.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    _navigateBasedOnAuth();
  }

  Future<void> _navigateBasedOnAuth() async {
    // Wait for the splash screen presentation time
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, ascertain their role
      String? role;
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          role = doc.data()?['role'];
        }
      } catch (e) {
        debugPrint("Error fetching role on startup: \$e");
      }

      if (!mounted) {
        return;
      }

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      }
    } else {
      // Not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home_work_rounded,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'RealEstate',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
