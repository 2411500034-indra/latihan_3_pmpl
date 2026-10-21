import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'hide AuthProvider;

class AuthProvider extends ChangeNotifier {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? _user;

  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;

  bool get isAuthenticated => _user != null;
  String? get token => null; // Placeholder for token management

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  
  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = cred.user;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _pesanError(e.code);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = cred.user;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _pesanError(e.code);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
   String _pesanError(String kode) {
   if (kode == 'user-not-found' || kode == 'invalid-credential') {
    return 'Email atau password salah';
    } 
    if (kode == 'email-already-in-use') {
      return 'Email ini telah digunakan';
    }
    if (kode == 'weak-password') {
      return 'Password minimal 6 karakter';
    }
    if (kode == 'invalid-email') {
      return 'Format email salah';
    }
    if (kode == 'confirmation-not-found') {
      return 'auth belum di aktifkan, cek console untuk melihat link konfirmasi';
    }
    if (kode == 'network-request-failed') {
      return 'Tidak ada koneksi internet';
    }
    return 'Terjadi kesalahan,($kode)';
  }
}