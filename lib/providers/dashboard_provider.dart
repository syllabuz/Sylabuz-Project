import 'package:flutter/material.dart';
import '../services/dashboard_service.dart'; // ← FIX: Path yang benar

class DashboardProvider with ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _programs = [];
  List<dynamic> _recentTasks = [];
  Map<String, dynamic> _stats = {};
  List<dynamic> _recentFeedback = [];
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<dynamic> get programs => _programs;
  List<dynamic> get recentTasks => _recentTasks;
  Map<String, dynamic> get stats => _stats;
  List<dynamic> get recentFeedback => _recentFeedback;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadDashboardData() async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await DashboardService.getDashboardData();

      if (response['success'] == true) {
        _dashboardData = response['data'];
        _recentTasks = response['data']['recent_tasks'] ?? [];
        _stats = response['data']['stats'] ?? {};
        _recentFeedback = response['data']['recent_feedback'] ?? [];

        // Also load programs
        await loadPrograms();
      } else {
        _setError(response['message'] ?? 'Failed to load dashboard data');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPrograms() async {
    try {
      final response = await DashboardService.getPrograms();

      if (response['success'] == true) {
        _programs = response['data']['programs'] ?? [];
        notifyListeners();
      }
    } catch (e) {
      print('Error loading programs: $e');
    }
  }

  // Helper methods
  String get userName {
    final user = _dashboardData?['user'];
    return user?['full_name'] ?? 'User';
  }

  double get overallProgress {
    return (_stats['overall_progress'] ?? 0.0).toDouble();
  }

  int get pendingTasks {
    return _stats['pending_tasks'] ?? 0;
  }

  int get overdueTasks {
    return _stats['overdue_tasks'] ?? 0;
  }

  int get unreadNotifications {
    return _stats['unread_notifications'] ?? 0;
  }

  String get currentProgram {
    final enrollment = _dashboardData?['active_enrollment'];
    return enrollment?['program']?['name'] ?? 'No Active Program';
  }

  String get currentWeek {
    final enrollment = _dashboardData?['active_enrollment'];
    final currentWeek = enrollment?['current_week'] ?? 0;
    final totalWeeks = enrollment?['program']?['total_weeks'] ?? 0;
    return '$currentWeek of $totalWeeks';
  }
}
