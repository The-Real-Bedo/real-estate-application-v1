import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../shared/custom_buttons.dart';
import '../../theme/app_theme.dart';
import '../main_layout.dart';

class SignupScreen extends StatefulWidget {
  final String role;
  const SignupScreen({super.key, this.role = 'buyer'});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _accountFormKey = GlobalKey<FormState>();
  final _profileFormKey = GlobalKey<FormState>();

  int _currentStep = 1;
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_accountFormKey.currentState!.validate()) {
      setState(() => _currentStep = 2);
    }
  }

  void _prevStep() {
    setState(() => _currentStep = 1);
  }

  Future<void> _submitSignup() async {
    if (!_profileFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.signUp(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      fullName: _nameCtrl.text.trim(),
      role: widget.role,
      phone: _phoneCtrl.text.trim(),
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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAccountStep = _currentStep == 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepHeader(currentStep: _currentStep, role: widget.role),
              const SizedBox(height: 28),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isAccountStep
                    ? _AccountStep(
                        key: const ValueKey('account'),
                        formKey: _accountFormKey,
                        emailCtrl: _emailCtrl,
                        passCtrl: _passCtrl,
                        confirmPassCtrl: _confirmPassCtrl,
                        hidePassword: _hidePassword,
                        hideConfirmPassword: _hideConfirmPassword,
                        onTogglePassword: () {
                          setState(() => _hidePassword = !_hidePassword);
                        },
                        onToggleConfirmPassword: () {
                          setState(
                            () => _hideConfirmPassword = !_hideConfirmPassword,
                          );
                        },
                      )
                    : _ProfileStep(
                        key: const ValueKey('profile'),
                        formKey: _profileFormKey,
                        nameCtrl: _nameCtrl,
                        phoneCtrl: _phoneCtrl,
                      ),
              ),
              const SizedBox(height: 28),
              if (isAccountStep)
                PrimaryButton(
                  text: 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _nextStep,
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _prevStep,
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        isLoading: _isLoading,
                        text: 'Create Account',
                        icon: Icons.check_rounded,
                        onPressed: _submitSignup,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final int currentStep;
  final String role;

  const _StepHeader({required this.currentStep, required this.role});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            role.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          currentStep == 1 ? 'Account details' : 'Personal details',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 8),
        Text(
          currentStep == 1
              ? 'Use a valid email and a strong password.'
              : 'Tell us who owns this account.',
          style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _StepBar(isActive: currentStep >= 1)),
            const SizedBox(width: 8),
            Expanded(child: _StepBar(isActive: currentStep >= 2)),
          ],
        ),
      ],
    );
  }
}

class _StepBar extends StatelessWidget {
  final bool isActive;

  const _StepBar({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : AppTheme.border,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _AccountStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmPassCtrl;
  final bool hidePassword;
  final bool hideConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  const _AccountStep({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmPassCtrl,
    required this.hidePassword,
    required this.hideConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailCtrl,
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
            controller: passCtrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            obscureText: hidePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              helperText:
                  'At least 8 chars, with uppercase, lowercase and number.',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: onTogglePassword,
              ),
            ),
            validator: (value) {
              final password = value?.trim() ?? '';
              if (password.isEmpty) {
                return 'Please enter a password.';
              }
              if (!_isStrongPassword(password)) {
                return 'Password must include upper, lower and number.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: confirmPassCtrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            obscureText: hideConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  hideConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: onToggleConfirmPassword,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password.';
              }
              if (value != passCtrl.text) {
                return "Passwords don't match.";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;

  const _ProfileStep({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.phoneCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameCtrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().length < 3) {
                return 'Please enter your full name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: phoneCtrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '01XXXXXXXXX',
              helperText: 'start with 010, 011, 012 or 015.',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: (value) {
              final phone = value?.trim() ?? '';
              if (!_isValidEgyptianPhone(phone)) {
                return 'Enter a valid mobile number.';
              }
              return null;
            },
          ),
        ],
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

bool _isStrongPassword(String password) {
  final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
  final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
  final hasNumber = RegExp(r'\d').hasMatch(password);
  return password.length >= 8 && hasUppercase && hasLowercase && hasNumber;
}

bool _isValidEgyptianPhone(String phone) {
  return RegExp(r'^01[0125]\d{8}$').hasMatch(phone);
}
