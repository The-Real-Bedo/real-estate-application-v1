import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _user;
  String? _userRole;

  User? get user => _user;
  String? get userRole => _userRole;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _fetchUserRole(user.uid);
      } else {
        _userRole = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _userRole = doc.get('role');
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching role: \$e");
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Admin Override
      if (email == 'abdo.bakr.23.11@gmail.com') {
        role = 'admin';
      }
      
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email,
        'fullName': fullName,
        'role': role,
        'favorites': [],
      });
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
