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

  // 🚀 FIXED: Proper logout with navigation
  Future<void> logout(BuildContext context) async {
    try {
      _setLoading(true);
      _setError(null);

      // Call logout service (with timeout protection)
      await AuthService.logout().timeout(
        Duration(seconds: 5),
        onTimeout: () {
          print('Logout API timeout, but continuing with local logout...');
        },
      );

      // Clear user data
      _user = null;
    } catch (e) {
      print('Logout error: $e (but continuing with local logout)');
      _setError(null); // Don't show error to user for logout
    } finally {
      // ALWAYS clear loading state and navigate
      _setLoading(false);

      // Navigate to login screen
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login', // Make sure this route exists
          (route) => false,
        );
      }
    }
  }

  // 🚀 ALTERNATIVE: Logout without navigation (for custom handling)
  Future<bool> logoutWithoutNavigation() async {
    try {
      _setLoading(true);
      _setError(null);

      await AuthService.logout().timeout(
        Duration(seconds: 5),
        onTimeout: () {
          print('Logout API timeout, but continuing...');
        },
      );

      _user = null;
      return true;
    } catch (e) {
      print('Logout error: $e');
      _setError(null); // Don't show error for logout
      return true; // Still return success for local logout
    } finally {
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
