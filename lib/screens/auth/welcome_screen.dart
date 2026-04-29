import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'role_selection_screen.dart';
import '../../shared/custom_buttons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(Icons.home_work_rounded, size: 100, color: Colors.blue),
              const SizedBox(height: 32),
              Text(
                'Welcome to RealEstate',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Buy, Rent, or Sell properties with ease.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              PrimaryButton(
                text: 'Login',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Create an Account',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                  );
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
