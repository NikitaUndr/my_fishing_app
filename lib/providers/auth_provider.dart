import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  AuthProvider() {
    _authService.user.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  Future<String?> signUp(String email, String password) async {
    try {
      User? user = await _authService.signUpWithEmail(email, password);
      if (user == null) return 'Registration failed';
      return null;
    } catch (e) {
      print('🔥 Ошибка регистрации: $e'); // временная печать
      return e.toString();
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      User? user = await _authService.signInWithEmail(email, password);
      if (user == null) return 'Login failed';
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}