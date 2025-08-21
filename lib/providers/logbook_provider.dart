import 'package:flutter/material.dart';
import '../services/logbook_service.dart';

class LogbookProvider with ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _logbookEntries = [];
  String? _error;
  bool _isCreating = false;

  // Getters
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get logbookEntries => _logbookEntries;
  String? get error => _error;
  bool get isCreating => _isCreating;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setCreating(bool creating) {
    _isCreating = creating;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Load all logbook entries
  Future<void> loadLogbookEntries() async {
    try {
      print('🚀 LogbookProvider: Starting loadLogbookEntries()...');
      _setLoading(true);
      _setError(null);

      final response = await LogbookService.getLogbookEntries();

      if (response['success'] == true) {
        final data = response['data'];
        _logbookEntries = List<Map<String, dynamic>>.from(
          data['entries'] ?? [],
        );
        print(
          '📊 LogbookProvider: Found ${_logbookEntries.length} logbook entries',
        );

        // Sort entries by date (newest first)
        _logbookEntries.sort(
          (a, b) =>
              DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])),
        );

        print(
          '✅ LogbookProvider: Final logbook entries count: ${_logbookEntries.length}',
        );
      } else {
        final message = response['message'] ?? 'Failed to load logbook entries';
        print('📭 LogbookProvider: API error: $message');
        _setError(message);
      }
    } catch (e) {
      final errorMessage = e.toString();
      print('❌ LogbookProvider error: $errorMessage');
      _setError(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Create new logbook entry
  Future<bool> createLogbookEntry({
    required String date,
    required String description,
    String? attachmentPath,
  }) async {
    try {
      print('📝 LogbookProvider: Creating new entry for date: $date');
      _setCreating(true);
      _setError(null);

      final response = await LogbookService.createLogbookEntry(
        date: date,
        description: description,
        attachmentPath: attachmentPath,
      );

      if (response['success'] == true) {
        print('✅ LogbookProvider: Entry created successfully');
        await loadLogbookEntries(); // Refresh list
        return true;
      } else {
        final message = response['message'] ?? 'Failed to create logbook entry';
        _setError(message);
        return false;
      }
    } catch (e) {
      final errorMessage = e.toString();
      print('❌ LogbookProvider create error: $errorMessage');
      _setError(errorMessage);
      return false;
    } finally {
      _setCreating(false);
    }
  }

  // Update existing logbook entry
  Future<bool> updateLogbookEntry({
    required int entryId,
    required String date,
    required String description,
    String? attachmentPath,
  }) async {
    try {
      print('✏️ LogbookProvider: Updating entry ID: $entryId');
      _setCreating(true);
      _setError(null);

      final response = await LogbookService.updateLogbookEntry(
        entryId: entryId,
        date: date,
        description: description,
        attachmentPath: attachmentPath,
      );

      if (response['success'] == true) {
        print('✅ LogbookProvider: Entry updated successfully');
        await loadLogbookEntries(); // Refresh list
        return true;
      } else {
        final message = response['message'] ?? 'Failed to update logbook entry';
        _setError(message);
        return false;
      }
    } catch (e) {
      final errorMessage = e.toString();
      print('❌ LogbookProvider update error: $errorMessage');
      _setError(errorMessage);
      return false;
    } finally {
      _setCreating(false);
    }
  }

  // Delete logbook entry
  Future<bool> deleteLogbookEntry(int entryId) async {
    try {
      print('🗑️ LogbookProvider: Deleting entry ID: $entryId');
      _setError(null);

      final response = await LogbookService.deleteLogbookEntry(entryId);

      if (response['success'] == true) {
        print('✅ LogbookProvider: Entry deleted successfully');
        await loadLogbookEntries(); // Refresh list
        return true;
      } else {
        final message = response['message'] ?? 'Failed to delete logbook entry';
        _setError(message);
        return false;
      }
    } catch (e) {
      final errorMessage = e.toString();
      print('❌ LogbookProvider delete error: $errorMessage');
      _setError(errorMessage);
      return false;
    }
  }

  // Helper methods
  List<Map<String, dynamic>> get todaysEntries {
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return _logbookEntries
        .where((entry) => entry['date'].toString().startsWith(todayString))
        .toList();
  }

  List<Map<String, dynamic>> get thisWeekEntries {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return _logbookEntries.where((entry) {
      final entryDate = DateTime.parse(entry['date']);
      return entryDate.isAfter(weekStart) &&
          entryDate.isBefore(now.add(Duration(days: 1)));
    }).toList();
  }

  int get totalEntries => _logbookEntries.length;

  int get thisMonthEntries {
    final now = DateTime.now();
    return _logbookEntries.where((entry) {
      final entryDate = DateTime.parse(entry['date']);
      return entryDate.month == now.month && entryDate.year == now.year;
    }).length;
  }
}
