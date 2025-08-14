import 'api_service.dart';
import 'storage_service.dart';
import '../config/api_config.dart';

class AuthService {
  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(ApiConfig.login, {
        'email': email,
        'password': password,
      }, includeAuth: false);

      if (response['success'] == true) {
        final token = response['data']['token'];
        await StorageService.saveToken(token);
        await StorageService.saveUserData(response['data']['user']);
        return response;
      } else {
        throw ApiException(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Register
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await ApiService.post(ApiConfig.register, {
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'full_name': fullName,
      }, includeAuth: false);

      if (response['success'] == true) {
        final token = response['data']['token'];
        await StorageService.saveToken(token);
        await StorageService.saveUserData(response['data']['user']);
        return response;
      } else {
        throw ApiException(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      await ApiService.post(ApiConfig.logout, {});
    } catch (e) {
      // Even if API call fails, still logout locally
      print('Logout API failed: $e');
    } finally {
      await StorageService.removeToken();
      await StorageService.removeUserData();
    }
  }

  // Get current user
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      return await ApiService.get(ApiConfig.me);
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return StorageService.isLoggedIn();
  }
}
