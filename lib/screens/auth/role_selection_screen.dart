import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'signup_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  void _confirmSelection() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose your account type.')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SignupScreen(role: _selectedRole!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Role')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What do you want to do?',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'This helps the app show the right options for you.',
                style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 28),
              _RoleCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Buy',
                subtitle: 'Browse properties for sale.',
                isSelected: _selectedRole == 'buy',
                onTap: () => setState(() => _selectedRole = 'buy'),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.key_outlined,
                title: 'Rent',
                subtitle: 'Find properties available for rent.',
                isSelected: _selectedRole == 'rent',
                onTap: () => setState(() => _selectedRole = 'rent'),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.real_estate_agent_outlined,
                title: 'Owner',
                subtitle: 'Add your own properties for admin approval.',
                isSelected: _selectedRole == 'owner',
                onTap: () => setState(() => _selectedRole = 'owner'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Continue'),
                onPressed: _confirmSelection,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? AppTheme.primary : AppTheme.border,
            ),
          ],
        ),
      ),
    );
  }
}
