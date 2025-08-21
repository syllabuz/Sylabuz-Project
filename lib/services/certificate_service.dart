// lib/services/certificate_service.dart
import 'api_service.dart';
import '../config/api_config.dart';

class CertificateService {
  // Get all certificates for current user
  static Future<Map<String, dynamic>> getCertificates() async {
    try {
      print('🏆 CertificateService: Getting user certificates');
      final response = await ApiService.get(ApiConfig.certificates);
      print('📥 CertificateService: Raw API response: $response');
      return response;
    } catch (e) {
      print('💥 CertificateService: Exception in getCertificates: $e');
      rethrow;
    }
  }

  // Get certificate detail
  static Future<Map<String, dynamic>> getCertificateDetail(
    int certificateId,
  ) async {
    try {
      print(
        '📜 CertificateService: Getting certificate detail ID: $certificateId',
      );
      final response = await ApiService.get(
        '${ApiConfig.certificates}/$certificateId',
      );
      print('✅ CertificateService: Certificate detail retrieved');
      return response;
    } catch (e) {
      print('💥 CertificateService: Exception in getCertificateDetail: $e');
      rethrow;
    }
  }

  // Generate certificate for program
  static Future<Map<String, dynamic>> generateCertificate(int programId) async {
    try {
      print(
        '🎓 CertificateService: Generating certificate for program ID: $programId',
      );
      final response = await ApiService.post(
        '${ApiConfig.certificates}/generate/$programId',
        {},
      );
      print('✅ CertificateService: Certificate generated successfully');
      return response;
    } catch (e) {
      print('💥 CertificateService: Exception in generateCertificate: $e');
      rethrow;
    }
  }

  // Download certificate (returns download URL)
  static String getCertificateDownloadUrl(int certificateId) {
    return '${ApiConfig.baseUrl}${ApiConfig.certificates}/$certificateId/download';
  }

  // Check program completion status
  static Future<Map<String, dynamic>> checkProgramCompletion(
    int programId,
  ) async {
    try {
      print(
        '📊 CertificateService: Checking program completion for ID: $programId',
      );
      final response = await ApiService.get(
        '${ApiConfig.programs}/$programId/completion',
      );
      print('✅ CertificateService: Program completion status retrieved');
      return response;
    } catch (e) {
      print('💥 CertificateService: Exception in checkProgramCompletion: $e');
      rethrow;
    }
  }

  // Verify certificate with certificate number
  static Future<Map<String, dynamic>> verifyCertificate(
    String certificateNumber,
  ) async {
    try {
      print('🔍 CertificateService: Verifying certificate: $certificateNumber');
      final response = await ApiService.get(
        '${ApiConfig.certificates}/verify/$certificateNumber',
      );
      print('✅ CertificateService: Certificate verification completed');
      return response;
    } catch (e) {
      print('💥 CertificateService: Exception in verifyCertificate: $e');
      rethrow;
    }
  }
}
