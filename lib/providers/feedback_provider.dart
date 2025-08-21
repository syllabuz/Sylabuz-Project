import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

class FeedbackProvider with ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _receivedFeedback = [];
  List<Map<String, dynamic>> _givenFeedback = [];
  String? _error;
  bool _isCreating = false;
  int _selectedTab = 0;

  // Getters
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get receivedFeedback => _receivedFeedback;
  List<Map<String, dynamic>> get givenFeedback => _givenFeedback;
  String? get error => _error;
  bool get isCreating => _isCreating;
  int get selectedTab => _selectedTab;

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

  void setSelectedTab(int tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  // Load received feedback
  Future<void> loadReceivedFeedback() async {
    try {
      print('🚀 FeedbackProvider: Starting loadReceivedFeedback()...');
      _setLoading(true);
      _setError(null);

      final response = await FeedbackService.getReceivedFeedback();

      if (response['success'] == true) {
        final data = response['data'];
        _receivedFeedback = List<Map<String, dynamic>>.from(
          data['feedback'] ?? [],
        );
        print(
          '📊 FeedbackProvider: Found ${_receivedFeedback.length} received feedback',
        );

        // Sort by newest first
        _receivedFeedback.sort(
          (a, b) => DateTime.parse(
            b['created_at'],
          ).compareTo(DateTime.parse(a['created_at'])),
        );
      } else {
        final message = response['message'] ?? 'Failed to load feedback';
        print('📭 FeedbackProvider: API error: $message');
        _setError(message);
      }
    } catch (e) {
      final errorMessage = e.toString();
      print('❌ FeedbackProvider error: $errorMessage');
      _setError(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Load given feedback (for mentors)
  Future<void> loadGivenFeedback() async {
    try {
      print('🚀 FeedbackProvider: Starting loadGivenFeedback()...');
      _setLoading(true);
      _setError(null);

      final response = await FeedbackService.getGivenFeedback();

      if (response['success'] == true) {
        final data = response['data'];
        _givenFeedback = List<Map<String, dynamic>>.from(
          data['feedback'] ?? [],
        );
        print(
          '📊 FeedbackProvider: Found ${_givenFeedback.length} given feedback',
        );

        // Sort by newest first
        _givenFeedback.sort(
          (a, b) => DateTime.parse(
            b['created_at'],
          ).compareTo(DateTime.parse(a['created_at'])),
        );
      } else {
        final message = response['message'] ?? 'Failed to load feedback';
        print('📭 FeedbackProvider: API error: $message');
        _setError(message);
      }
    } catch (e) {
      final errorMessage = e.toString();
      print('❌ FeedbackProvider error: $errorMessage');
      _setError(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Load all feedback based on current tab
  Future<void> loadAllFeedback() async {
    if (_selectedTab == 0) {
      await loadReceivedFeedback();
    } else {
      await loadGivenFeedback();
    }
  }

  // Create feedback (for mentors)
  Future<bool> createFeedback({
    required int toUserId,
    int? taskId,
    int? weekId,
    required String feedbackType,
    required String comment,
    required int rating,
  }) async {
    try {
      print('📝 FeedbackProvider: Creating feedback for user: $toUserId');
      _setCreating(true);
      _setError(null);

      final response = await FeedbackService.createFeedback(
        toUserId: toUserId,
        taskId: taskId,
        weekId: weekId,
        feedbackType: feedbackType,
        comment: comment,
        rating: rating,
      );

      if (response['success'] == true) {
        print('✅ FeedbackProvider: Feedback created successfully');
        await loadAllFeedback(); // Refresh list
        return true;
      } else {
        final message = response['message'] ?? 'Failed to create feedback';
        _setError(message);
        return false;
      }
    } catch (e) {
      final errorMessage = e.toString();
      print('❌ FeedbackProvider create error: $errorMessage');
      _setError(errorMessage);
      return false;
    } finally {
      _setCreating(false);
    }
  }

  // Helper methods
  List<Map<String, dynamic>> get taskFeedback {
    return _receivedFeedback
        .where((feedback) => feedback['feedback_type'] == 'task')
        .toList();
  }

  List<Map<String, dynamic>> get weekFeedback {
    return _receivedFeedback
        .where(
          (feedback) =>
              feedback['feedback_type'] == 'week' ||
              feedback['feedback_type'] == 'syllabus',
        )
        .toList();
  }

  List<Map<String, dynamic>> get generalFeedback {
    return _receivedFeedback
        .where((feedback) => feedback['feedback_type'] == 'general')
        .toList();
  }

  double get averageRating {
    if (_receivedFeedback.isEmpty) return 0.0;

    final totalRating = _receivedFeedback.fold<double>(0.0, (sum, feedback) {
      return sum + (feedback['rating']?.toDouble() ?? 0.0);
    });

    return totalRating / _receivedFeedback.length;
  }

  int get totalFeedback => _receivedFeedback.length;

  int get thisMonthFeedback {
    final now = DateTime.now();
    return _receivedFeedback.where((feedback) {
      final feedbackDate = DateTime.parse(feedback['created_at']);
      return feedbackDate.month == now.month && feedbackDate.year == now.year;
    }).length;
  }
}
