import 'api_service.dart';
import '../config/api_config.dart';

class TaskService {
  static Future<Map<String, dynamic>> getAssignedTasks({String? status}) async {
    try {
      String endpoint = '${ApiConfig.tasks}/assigned';
      if (status != null) {
        endpoint += '?status=$status';
      }

      print('🚀 TaskService: Calling API endpoint: $endpoint');
      final response = await ApiService.get(endpoint);
      print('📥 TaskService: Raw API response: $response');

      return response;
    } catch (e) {
      print('💥 TaskService: Exception in getAssignedTasks: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getCreatedTasks() async {
    try {
      print('🚀 TaskService: Getting created tasks...');
      final response = await ApiService.get('${ApiConfig.tasks}/created');
      print('📥 TaskService: Created tasks response: $response');
      return response;
    } catch (e) {
      print('💥 TaskService: Exception in getCreatedTasks: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getTaskDetail(int taskId) async {
    try {
      final endpoint = '${ApiConfig.tasks}/$taskId';
      print('🚀 TaskService: Getting task detail: $endpoint');

      final response = await ApiService.get(endpoint);
      print('📥 TaskService: Task detail response: $response');

      return response;
    } catch (e) {
      print('💥 TaskService: Exception in getTaskDetail: $e');
      rethrow;
    }
  }

  // ✅ SIMPLE VERSION: Text-only submission for now
  static Future<Map<String, dynamic>> submitTask(
    int taskId,
    String description,
    String? filePath,
  ) async {
    try {
      print('📤 TaskService: Submitting task $taskId');
      print('📝 TaskService: Description: $description');
      print('📎 TaskService: File path: $filePath');

      // For now, just submit text description
      // File upload will be added later when multipart is working
      final data = {'description': description};

      // Add file path info for Laravel to handle
      if (filePath != null) {
        data['has_file'] = 'true';
        data['file_name'] = filePath.split('/').last;
        print('📎 TaskService: Will upload file later: ${data['file_name']}');
      }

      print('📝 TaskService: Submitting data: $data');
      final response = await ApiService.post(
        '${ApiConfig.tasks}/$taskId/submit',
        data,
      );
      print('📥 TaskService: Submit response: $response');

      return response;
    } catch (e) {
      print('💥 TaskService: Exception in submitTask: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createTask({
    required int assignedTo,
    required String title,
    required String description,
    required String deadline,
    String priority = 'medium',
  }) async {
    try {
      print('🚀 TaskService: Creating new task...');
      print('👤 TaskService: Assigned to: $assignedTo');
      print('📝 TaskService: Title: $title');

      final response = await ApiService.post(ApiConfig.tasks, {
        'assigned_to': assignedTo,
        'title': title,
        'description': description,
        'deadline': deadline,
        'priority': priority,
      });

      print('📥 TaskService: Create task response: $response');
      return response;
    } catch (e) {
      print('💥 TaskService: Exception in createTask: $e');
      rethrow;
    }
  }
}
