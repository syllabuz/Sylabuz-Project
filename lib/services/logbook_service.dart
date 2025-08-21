// lib/services/logbook_service.dart
import 'api_service.dart';
import '../config/api_config.dart';

class LogbookService {
  // Get all logbook entries for current user
  static Future<Map<String, dynamic>> getLogbookEntries() async {
    try {
      print('🚀 LogbookService: Calling API endpoint: ${ApiConfig.logbook}');
      final response = await ApiService.get(ApiConfig.logbook);
      print('📥 LogbookService: Raw API response: $response');
      return response;
    } catch (e) {
      print('💥 LogbookService: Exception in getLogbookEntries: $e');
      rethrow;
    }
  }

  // Create new logbook entry
  static Future<Map<String, dynamic>> createLogbookEntry({
    required String date,
    required String description,
    String? attachmentPath,
  }) async {
    try {
      print('📝 LogbookService: Creating logbook entry for date: $date');

      Map<String, dynamic> data = {'date': date, 'description': description};

      if (attachmentPath != null) {
        print('📎 LogbookService: Entry has attachment');
        data['attachment_path'] = attachmentPath;
      }

      final response = await ApiService.post(ApiConfig.logbook, data);
      print('✅ LogbookService: Entry created successfully');
      return response;
    } catch (e) {
      print('💥 LogbookService: Exception in createLogbookEntry: $e');
      rethrow;
    }
  }

  // 🚀 FIXED: Update existing logbook entry using PUT method
  static Future<Map<String, dynamic>> updateLogbookEntry({
    required int entryId,
    required String date,
    required String description,
    String? attachmentPath,
  }) async {
    try {
      print('✏️ LogbookService: Updating logbook entry ID: $entryId');

      Map<String, dynamic> data = {'date': date, 'description': description};

      if (attachmentPath != null) {
        data['attachment_path'] = attachmentPath;
      }

      // 🚀 USE PUT METHOD (no more POST)
      final response = await ApiService.put(
        '${ApiConfig.logbook}/$entryId', // ← Clean endpoint: /api/logbook/{id}
        data,
      );
      print('✅ LogbookService: Entry updated successfully');
      return response;
    } catch (e) {
      print('💥 LogbookService: Exception in updateLogbookEntry: $e');
      rethrow;
    }
  }

  // 🚀 FIXED: Delete logbook entry using DELETE method
  static Future<Map<String, dynamic>> deleteLogbookEntry(int entryId) async {
    try {
      print('🗑️ LogbookService: Deleting logbook entry ID: $entryId');

      // 🚀 USE DELETE METHOD (no more POST, no /delete suffix)
      final response = await ApiService.delete(
        '${ApiConfig.logbook}/$entryId', // ← Clean endpoint: /api/logbook/{id}
      );
      print('✅ LogbookService: Entry deleted successfully');
      return response;
    } catch (e) {
      print('💥 LogbookService: Exception in deleteLogbookEntry: $e');
      rethrow;
    }
  }
}
