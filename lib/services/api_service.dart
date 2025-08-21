import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';
import 'dart:io';

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

  static String? _getToken() {
    return StorageService.getToken();
  }

  // ✅ FIXED: Added _handleResponse method
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw ApiException(responseData['message'] ?? 'Request failed');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Invalid response format');
    }
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

  // 🚀 NEW: PUT request (for updates)
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);

      print('🚀 PUT: $url');
      print('📤 Data: $data');

      final response = await http
          .put(url, headers: headers, body: jsonEncode(data))
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

  // 🚀 NEW: DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);

      print('🚀 DELETE: $url');

      final response = await http
          .delete(url, headers: headers)
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

  // 🚀 NEW: PATCH request (optional)
  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);

      print('🚀 PATCH: $url');
      print('📤 Data: $data');

      final response = await http
          .patch(url, headers: headers, body: jsonEncode(data))
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

  // Multipart upload method (if needed)
  static Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath,
    String fieldName, {
    Map<String, String>? additionalFields,
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: includeAuth);

      // Remove Content-Type for multipart
      headers.remove('Content-Type');

      print('🚀 UPLOAD: $url');
      print('📎 File: $filePath');

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      // Add file
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(
        Duration(
          milliseconds: ApiConfig.timeout * 2,
        ), // Double timeout for uploads
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Upload Response: ${response.statusCode}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw ApiException(responseData['message'] ?? 'Upload failed');
      }
    } catch (e) {
      print('❌ Upload Error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Upload failed. Please check your connection.');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
