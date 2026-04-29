import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(text),
    );
  }
}

class OutlineSelectionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const OutlineSelectionButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.secondary : AppTheme.border,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const SocialButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppTheme.textPrimary),
      label: Text(
        text,
        style: const TextStyle(color: AppTheme.textPrimary),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppTheme.border),
      ),
    );
  }
}
