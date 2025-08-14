import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiService {
  static Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = StorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // POST request (for login, register)
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);

      print('🚀 POST: $url');
      print('📤 Data: $data');

      final response = await http
          .post(url, headers: headers, body: jsonEncode(data))
          .timeout(Duration(milliseconds: ApiConfig.timeout));

      print('📥 Response: ${response.statusCode}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw ApiException(responseData['message'] ?? 'Request failed');
      }
    } catch (e) {
      print('❌ Error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Network error. Please check your connection.');
    }
  }

  // GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();

      print('🚀 GET: $url');

      final response = await http
          .get(url, headers: headers)
          .timeout(Duration(milliseconds: ApiConfig.timeout));

      print('📥 Response: ${response.statusCode}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw ApiException(responseData['message'] ?? 'Request failed');
      }
    } catch (e) {
      print('❌ Error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Network error. Please check your connection.');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
