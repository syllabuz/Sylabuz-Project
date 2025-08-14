import 'api_service.dart';
import '../config/api_config.dart';

class SyllabusService {
  static Future<Map<String, dynamic>> getWeeks() async {
    try {
      return await ApiService.get(ApiConfig.weeks);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getWeekDetail(int weekId) async {
    try {
      return await ApiService.get('${ApiConfig.weeks}/$weekId');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getWeekContent(int weekId) async {
    try {
      return await ApiService.get('${ApiConfig.weeks}/$weekId/content');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> startWeek(int weekId) async {
    try {
      return await ApiService.post('${ApiConfig.weeks}/$weekId/start', {});
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> completeVideo(int weekId) async {
    try {
      return await ApiService.post(
        '${ApiConfig.weeks}/$weekId/complete-video',
        {},
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> completePdf(int weekId) async {
    try {
      return await ApiService.post(
        '${ApiConfig.weeks}/$weekId/complete-pdf',
        {},
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> submitQuiz(
    int weekId,
    List<int> answers,
  ) async {
    try {
      return await ApiService.post('${ApiConfig.weeks}/$weekId/submit-quiz', {
        'answers': answers,
      });
    } catch (e) {
      rethrow;
    }
  }
}
