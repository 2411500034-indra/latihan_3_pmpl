import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.length >= 6) {
      _isAuthenticated = true;
      _token = 'dummy_token_dummy_12345';
      notifyListeners();
      return true;
    } 
    return false;
  }
  void logout() {
    _isAuthenticated = false;
    _token = null;
    notifyListeners();
  }
}
