import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;
  String? _token;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userData => _userData;
  String? get token => _token;

  // Initialize auth state
  Future<void> initialize() async {
    _token = await AuthService.getToken();
    _isLoggedIn = _token != null;
    if (_isLoggedIn) {
      _userData = await AuthService.getCurrentUser();
    }
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      final result = await AuthService.login(email, password);
      if (result['success']) {
        _token = result['token'];
        _isLoggedIn = true;
        _userData = await AuthService.getCurrentUser();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    int? age,
    String? gender,
  }) async {
    try {
      final result = await AuthService.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        age: age,
        gender: gender,
      );
      if (result['success']) {
        _token = result['token'];
        _isLoggedIn = true;
        _userData = await AuthService.getCurrentUser();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _isLoggedIn = false;
    _userData = null;
    _token = null;
    notifyListeners();
  }

  // Update user data
  Future<void> updateUserData() async {
    if (_isLoggedIn) {
      _userData = await AuthService.getCurrentUser();
      notifyListeners();
    }
  }
}
