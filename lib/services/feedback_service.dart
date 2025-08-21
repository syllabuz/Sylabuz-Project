import 'api_service.dart';
import '../config/api_config.dart';

class FeedbackService {
  // Get all feedback received by current user
  static Future<Map<String, dynamic>> getReceivedFeedback() async {
    try {
      print(
        '🚀 FeedbackService: Calling API endpoint: ${ApiConfig.feedback}/received',
      );
      final response = await ApiService.get('${ApiConfig.feedback}/received');
      print('📥 FeedbackService: Raw API response: $response');
      return response;
    } catch (e) {
      print('💥 FeedbackService: Exception in getReceivedFeedback: $e');
      rethrow;
    }
  }

  // Get all feedback given by current user (for mentors)
  static Future<Map<String, dynamic>> getGivenFeedback() async {
    try {
      print(
        '🚀 FeedbackService: Calling API endpoint: ${ApiConfig.feedback}/given',
      );
      final response = await ApiService.get('${ApiConfig.feedback}/given');
      print('📥 FeedbackService: Raw API response: $response');
      return response;
    } catch (e) {
      print('💥 FeedbackService: Exception in getGivenFeedback: $e');
      rethrow;
    }
  }

  // Get feedback details
  static Future<Map<String, dynamic>> getFeedbackDetail(int feedbackId) async {
    try {
      print('🔍 FeedbackService: Getting feedback detail ID: $feedbackId');
      final response = await ApiService.get(
        '${ApiConfig.feedback}/$feedbackId',
      );
      print('📥 FeedbackService: Feedback detail response: $response');
      return response;
    } catch (e) {
      print('💥 FeedbackService: Exception in getFeedbackDetail: $e');
      rethrow;
    }
  }

  // Create new feedback (for mentors)
  static Future<Map<String, dynamic>> createFeedback({
    required int toUserId,
    int? taskId,
    int? weekId,
    required String feedbackType,
    required String comment,
    required int rating,
  }) async {
    try {
      print('📝 FeedbackService: Creating feedback for user: $toUserId');

      Map<String, dynamic> data = {
        'to_user_id': toUserId,
        'feedback_type': feedbackType,
        'comment': comment,
        'rating': rating,
      };

      if (taskId != null) {
        data['task_id'] = taskId;
      }

      if (weekId != null) {
        data['week_id'] = weekId;
      }

      final response = await ApiService.post(ApiConfig.feedback, data);
      print('✅ FeedbackService: Feedback created successfully');
      return response;
    } catch (e) {
      print('💥 FeedbackService: Exception in createFeedback: $e');
      rethrow;
    }
  }
}
