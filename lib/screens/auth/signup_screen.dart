import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../shared/custom_buttons.dart';
import '../../shared/custom_inputs.dart'; // No longer purely stateless, we will need to adjust CustomTextInput to take a controller.
import '../main_layout.dart';
import '../admin/admin_dashboard.dart';

class SignupScreen extends StatefulWidget {
  final String role;
  const SignupScreen({Key? key, this.role = 'buyer'}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _currentStep = 1;

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  
  bool _isLoading = false;

  void _nextStep() {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
    if (_passCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords don't match!")));
      return;
    }
    setState(() => _currentStep = 2);
  }

  void _prevStep() {
    setState(() => _currentStep = 1);
  }

  Future<void> _submitSignup() async {
    setState(() => _isLoading = true);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    String? error = await authService.signUp(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      fullName: _nameCtrl.text.trim(),
      role: widget.role,
    );

    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        final role = authService.userRole;
        if (role == 'admin') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainLayout()),
            (route) => false,
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
                'Sign Up',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 48),
              if (_currentStep == 1) ...[
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPassCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline)),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Continue',
                  onPressed: _nextStep,
                ),
              ] else ...[
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(hintText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(hintText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade400),
                        onPressed: _prevStep,
                        child: const Text('Back', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        isLoading: _isLoading,
                        text: 'Confirm',
                        onPressed: _submitSignup,
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
