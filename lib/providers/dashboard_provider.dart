import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _programs = [];
  List<dynamic> _recentTasks = [];
  Map<String, dynamic> _stats = {};
  List<dynamic> _recentFeedback = [];
  List<dynamic> _syllabusWeeks = []; // ✅ ADD: Store actual syllabus weeks
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<dynamic> get programs => _programs;
  List<dynamic> get recentTasks => _recentTasks;
  Map<String, dynamic> get stats => _stats;
  List<dynamic> get recentFeedback => _recentFeedback;
  List<dynamic> get syllabusWeeks => _syllabusWeeks; // ✅ ADD: Getter for weeks
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

        // ✅ IMPORTANT: Load actual syllabus weeks
        await loadPrograms();
        await loadSyllabusWeeks(); // ← ADD THIS LINE
      } else {
        _setError(response['message'] ?? 'Failed to load dashboard data');
      }
    } catch (e) {
      _setError(e.toString());
      print('Dashboard error: $e'); // Debug
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

  // ✅ NEW METHOD: Load actual syllabus weeks from WeekController
  Future<void> loadSyllabusWeeks() async {
    try {
      print('🔄 DashboardProvider: Loading syllabus weeks...');
      final response = await DashboardService.getWeeks();

      if (response['success'] == true) {
        _syllabusWeeks = response['data']['weeks'] ?? [];
        print(
          '✅ DashboardProvider: Loaded ${_syllabusWeeks.length} syllabus weeks',
        );

        // Debug: Log week data
        for (var week in _syllabusWeeks) {
          print(
            '   Week ${week['week_number']}: ${week['title']} - Progress: ${week['user_progress']}',
          );
        }

        notifyListeners();
      } else {
        print('❌ Failed to load syllabus weeks: ${response['message']}');
      }
    } catch (e) {
      print('❌ Error loading syllabus weeks: $e');
    }
  }

  // Helper methods with NULL SAFETY
  String get userName {
    try {
      final user = _dashboardData?['user'];
      return user?['full_name']?.toString() ?? 'User';
    } catch (e) {
      print('Error getting userName: $e');
      return 'User';
    }
  }

  double get overallProgress {
    try {
      // Calculate based on actual completion data
      final totalWeeks = _syllabusWeeks.length;
      final completedWeeks = completedWeeksCount;

      if (totalWeeks > 0) {
        // Calculate week completion percentage
        double weekProgress = (completedWeeks / totalWeeks) * 100;

        // Calculate task completion percentage
        double taskProgress = 100.0; // Default to 100% if no tasks
        if (_recentTasks.isNotEmpty) {
          final completedTasks =
              _recentTasks.where((task) {
                if (task['status'] == null) return false;
                String status = task['status'].toString().toLowerCase();
                return [
                  'completed',
                  'reviewed',
                  'submitted',
                  'done',
                  'finished',
                  'approved',
                ].contains(status);
              }).length;
          taskProgress = (completedTasks / _recentTasks.length) * 100;
        }

        // Weighted calculation: 70% weeks + 30% tasks
        double calculatedProgress = (weekProgress * 0.7) + (taskProgress * 0.3);

        // Get backend progress as fallback
        double backendProgress = 0.0;
        final progress = _stats['overall_progress'];
        if (progress != null) {
          if (progress is String) {
            backendProgress = double.tryParse(progress) ?? 0.0;
          } else if (progress is int) {
            backendProgress = progress.toDouble();
          } else if (progress is double) {
            backendProgress = progress;
          }
        }

        // Use higher value: Real-time calculation vs Backend
        double finalProgress =
            calculatedProgress > backendProgress
                ? calculatedProgress
                : backendProgress;

        // Special case: If all weeks completed but tasks pending, cap at 90%
        if (completedWeeks == totalWeeks &&
            _recentTasks.isNotEmpty &&
            taskProgress < 100) {
          finalProgress = finalProgress > 90 ? 90.0 : finalProgress;
        }

        return finalProgress.clamp(0.0, 100.0);
      }

      // Fallback to backend data if no weeks data
      final progress = _stats['overall_progress'];
      if (progress == null) return 0.0;

      if (progress is String) {
        return double.tryParse(progress) ?? 0.0;
      }
      if (progress is int) {
        return progress.toDouble();
      }
      if (progress is double) {
        return progress;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  int get pendingTasks {
    try {
      final pending = _stats['pending_tasks'];
      if (pending == null) return 0;

      if (pending is String) {
        return int.tryParse(pending) ?? 0;
      }
      if (pending is double) {
        return pending.toInt();
      }
      return pending is int ? pending : 0;
    } catch (e) {
      print('Error getting pendingTasks: $e');
      return 0;
    }
  }

  int get overdueTasks {
    try {
      final overdue = _stats['overdue_tasks'];
      if (overdue == null) return 0;

      if (overdue is String) {
        return int.tryParse(overdue) ?? 0;
      }
      if (overdue is double) {
        return overdue.toInt();
      }
      return overdue is int ? overdue : 0;
    } catch (e) {
      print('Error getting overdueTasks: $e');
      return 0;
    }
  }

  int get unreadNotifications {
    try {
      final unread = _stats['unread_notifications'];
      if (unread == null) return 0;

      if (unread is String) {
        return int.tryParse(unread) ?? 0;
      }
      if (unread is double) {
        return unread.toInt();
      }
      return unread is int ? unread : 0;
    } catch (e) {
      print('Error getting unreadNotifications: $e');
      return 0;
    }
  }

  String get currentProgram {
    try {
      final enrollment = _dashboardData?['active_enrollment'];
      return enrollment?['program']?['name']?.toString() ?? 'No Active Program';
    } catch (e) {
      print('Error getting currentProgram: $e');
      return 'No Active Program';
    }
  }

  // ✅ FIXED: Use actual syllabus weeks count instead of program.total_weeks
  String get currentWeek {
    try {
      final enrollment = _dashboardData?['active_enrollment'];
      final currentWeek = enrollment?['current_week'] ?? 0;

      // ✅ Use actual syllabus weeks count (dynamic from database)
      final totalWeeks = _syllabusWeeks.length;

      // Safe conversion to int
      int current = 0;

      if (currentWeek is String) {
        current = int.tryParse(currentWeek) ?? 0;
      } else if (currentWeek is num) {
        current = currentWeek.toInt();
      }

      // ✅ SMART LOGIC: Handle completion scenarios
      int displayCurrent = current;
      String status = '';

      if (current > totalWeeks) {
        // User completed all weeks
        displayCurrent = totalWeeks;
        status = ' ✅'; // Add checkmark for completion
      } else if (current == 0) {
        // User hasn't started
        displayCurrent = 0;
      } else {
        // User in progress
        displayCurrent = current;
      }

      print('📊 DashboardProvider currentWeek calculation:');
      print('   - Backend current week: $current');
      print('   - Total syllabus weeks: $totalWeeks');
      print('   - Display current week: $displayCurrent');
      print(
        '   - Completion status: ${current > totalWeeks ? 'COMPLETED' : 'IN_PROGRESS'}',
      );
      print('   - Result: $displayCurrent of $totalWeeks$status');

      return '$displayCurrent of $totalWeeks$status';
    } catch (e) {
      print('Error getting currentWeek: $e');
      return '0 of 0';
    }
  }

  // ✅ NEW: Get completed weeks count from actual progress
  int get completedWeeksCount {
    try {
      return _syllabusWeeks.where((week) {
        final userProgress = week['user_progress'];
        if (userProgress == null || userProgress.isEmpty) return false;

        final progress =
            userProgress[0]; // First (and should be only) progress record
        return progress['status'] == 'completed';
      }).length;
    } catch (e) {
      print('Error getting completedWeeksCount: $e');
      return 0;
    }
  }

  // ✅ NEW: Get total weeks count (actual from database)
  int get totalWeeksCount {
    return _syllabusWeeks.length;
  }
}
