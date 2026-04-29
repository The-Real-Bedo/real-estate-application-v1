import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../../shared/custom_buttons.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

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
              Text(
                'Why are you here?',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: OutlineSelectionButton(
                      text: "I'm here to buy\na property",
                      isSelected: _selectedRole == 'buy',
                      onTap: () => setState(() => _selectedRole = 'buy'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlineSelectionButton(
                      text: "I'm here to rent\na property",
                      isSelected: _selectedRole == 'rent',
                      onTap: () => setState(() => _selectedRole = 'rent'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: OutlineSelectionButton(
                  text: "I'm an Owner",
                  isSelected: _selectedRole == 'owner',
                  onTap: () => setState(() => _selectedRole = 'owner'),
                ),
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Confirm selection',
                onPressed: () {
                  if (_selectedRole != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => SignupScreen(role: _selectedRole!)),
                    );
                  }
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
