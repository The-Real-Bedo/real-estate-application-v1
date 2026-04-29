import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import '../auth/login_screen.dart';
import '../owner/my_properties_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    await Provider.of<AuthService>(context, listen: false).logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final dbService = Provider.of<DatabaseService>(context, listen: false);

    if (authService.user == null) {
      return const Center(child: Text("Not logged in"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: dbService.getUserProfile(authService.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Error loading profile'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primary,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  userData['fullName'] ?? 'No Name',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  userData['email'] ?? '',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (userData['role'] ?? 'User').toUpperCase(),
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 48),
                if (authService.userRole == 'owner') 
                  ListTile(
                    leading: const Icon(Icons.home_work, color: AppTheme.primary),
                    title: const Text('My Properties', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPropertiesScreen()));
                    },
                  ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.error),
                  title: const Text('Logout', style: TextStyle(color: AppTheme.error)),
                  onTap: () => _logout(context),
                  tileColor: AppTheme.error.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
