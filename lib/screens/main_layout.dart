import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'admin/admin_dashboard.dart';
import 'home/home_screen.dart';
import 'favorites/favorites_screen.dart';
import 'profile/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthService>().userRole == 'admin';
    final screens = [
      const HomeScreen(),
      const FavoritesScreen(),
      if (isAdmin) const AdminDashboard(showLogout: false),
      const ProfileScreen(),
    ];
    final items = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.favorite_border),
        label: 'Favorites',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          label: 'Admin',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
    ];
    final selectedIndex = _currentIndex >= screens.length ? 0 : _currentIndex;

    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: items,
      ),
    );
  }
}
