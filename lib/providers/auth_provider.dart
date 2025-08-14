import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isLoggedIn => AuthService.isLoggedIn();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await AuthService.login(
        email: email,
        password: password,
      );

      _user = response['data']['user'];
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await AuthService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );

      _user = response['data']['user'];
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      await AuthService.logout();
      _user = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> getCurrentUser() async {
    try {
      final response = await AuthService.getCurrentUser();
      _user = response['data']['user'];
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
}
