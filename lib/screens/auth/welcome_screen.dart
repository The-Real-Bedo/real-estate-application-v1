import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';
import 'role_selection_screen.dart';
import '../../shared/custom_buttons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryDark,
              AppTheme.primary,
              AppTheme.background,
            ],
            stops: [0, 0.45, 0.45],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.maps_home_work_rounded,
                    size: 86,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'RealEstate',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Find your next home, save favorites, and let owners add properties for admin review.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      PrimaryButton(
                        text: 'Login',
                        icon: Icons.login_rounded,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Create an Account'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RoleSelectionScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
