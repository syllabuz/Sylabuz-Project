import 'api_service.dart';
import '../config/api_config.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      return await ApiService.get(ApiConfig.dashboard);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getPrograms() async {
    try {
      return await ApiService.get(ApiConfig.programs);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getWeeks() async {
    try {
      return await ApiService.get(ApiConfig.weeks);
    } catch (e) {
      rethrow;
    }
  }
}
