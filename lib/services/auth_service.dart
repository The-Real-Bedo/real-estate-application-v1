import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // In-memory user data store replacing Cloud Firestore 'users' collection
  static final Map<String, Map<String, dynamic>> _userStore = {};

  static Map<String, dynamic>? getUserData(String uid) => _userStore[uid];
  static void setUserData(String uid, Map<String, dynamic> data) =>
      _userStore[uid] = data;

  User? _user;
  String? _userRole;
  String? _fullName;
  late final StreamSubscription<User?> _authSubscription;

  User? get user => _user;
  String? get userRole => _userRole;
  String? get fullName => _fullName;
  String get firstName {
    final name = _fullName?.trim();
    if (name != null && name.isNotEmpty) {
      return name.split(RegExp(r'\s+')).first;
    }
    return _user?.email?.split('@').first ?? 'User';
  }

  AuthService() {
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _fetchUserRole(user.uid);
      } else {
        _userRole = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      final data = _userStore[uid];
      if (data != null) {
        _userRole = data['role']?.toString();
        _fullName = data['fullName']?.toString();
      } else {
        if (_user?.email == 'abdo.bakr.23.11@gmail.com') {
          _userRole = 'admin';
        } else {
          _userRole = 'buyer';
        }
        _fullName = _user?.displayName ?? _user?.email?.split('@').first ?? 'User';
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching role: $e');
    }
  }

  Future<String?> loadCurrentUserRole() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _user = null;
      _userRole = null;
      _fullName = null;
      notifyListeners();
      return null;
    }

    _user = currentUser;
    await _fetchUserRole(currentUser.uid);
    return _userRole;
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String phone = '',
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Admin Override
      if (email == 'abdo.bakr.23.11@gmail.com') {
        role = 'admin';
      }

      _userStore[cred.user!.uid] = {
        'uid': cred.user!.uid,
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'role': role,
        'favorites': <String>[],
      };
      await loadCurrentUserRole();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await loadCurrentUserRole();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
