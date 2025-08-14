import 'package:flutter/material.dart';
import '../services/syllabus_service.dart';

class SyllabusProvider with ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _weeks = [];
  int _currentWeek = 1;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  List<dynamic> get weeks => _weeks;
  int get currentWeek => _currentWeek;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadWeeks() async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await SyllabusService.getWeeks();

      if (response['success'] == true) {
        _weeks = response['data']['weeks'] ?? [];
        _currentWeek = response['data']['current_week'] ?? 1;
      } else {
        _setError(response['message'] ?? 'Failed to load syllabus data');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  Map<String, dynamic>? getWeekById(int weekId) {
    try {
      return _weeks.firstWhere((week) => week['id'] == weekId);
    } catch (e) {
      return null;
    }
  }

  List<dynamic> get availableWeeks {
    return _weeks.where((week) => week['week_number'] <= _currentWeek).toList();
  }

  bool canAccessWeek(int weekNumber) {
    return weekNumber <= _currentWeek;
  }

  String getWeekStatus(Map<String, dynamic> week) {
    final progress = week['user_progress'];
    if (progress == null || progress.isEmpty) {
      return 'not_started';
    }

    final userProgress = progress[0];
    return userProgress['status'] ?? 'not_started';
  }

  double getWeekProgress(Map<String, dynamic> week) {
    final progress = week['user_progress'];
    if (progress == null || progress.isEmpty) {
      return 0.0;
    }

    final userProgress = progress[0];
    int completed = 0;
    int total = 3;

    if (userProgress['video_watched'] == true) completed++;
    if (userProgress['pdf_read'] == true) completed++;
    if (userProgress['quiz_completed'] == true) completed++;

    return completed / total;
  }
}
