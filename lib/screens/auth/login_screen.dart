import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../shared/custom_buttons.dart';
import '../main_layout.dart';
import '../admin/admin_dashboard.dart';
import 'role_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitLogin() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    String? error = await authService.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        // Wait a small bit for the user object stream to update role
        await Future.delayed(const Duration(milliseconds: 500));
        
        final role = authService.userRole;
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
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Log in',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No account? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                      );
                    },
                    child: Text(
                      'Signup now!',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                isLoading: _isLoading,
                text: 'Login',
                onPressed: _submitLogin,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
