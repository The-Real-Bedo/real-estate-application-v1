import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../shared/custom_buttons.dart';
import '../../theme/app_theme.dart';
import '../main_layout.dart';
import 'role_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.login(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
    );

    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);

    if (error == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 44),
                const _AuthBadge(icon: Icons.lock_open_rounded),
                const SizedBox(height: 24),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to continue browsing properties.',
                  style: TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                TextFormField(
                  controller: _emailCtrl,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'name@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    helperText:
                        'Use the password you created for this account.',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() => _hidePassword = !_hidePassword);
                      },
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your password.';
                    }
                    if (value.trim().length < 6) {
                      return 'Password must be at least 6 characters.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submitLogin(),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  isLoading: _isLoading,
                  text: 'Login',
                  icon: Icons.login_rounded,
                  onPressed: _submitLogin,
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RoleSelectionScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Signup now',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'Please enter your email.';
  }
  final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
  if (!emailRegex.hasMatch(email)) {
    return 'Please enter a valid email.';
  }
  return null;
}

class _AuthBadge extends StatelessWidget {
  final IconData icon;
  const _AuthBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.22),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 40),
      ),
    );
  }
}
