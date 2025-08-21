import 'package:flutter/material.dart';
import '../services/certificate_service.dart';
import '../services/dashboard_service.dart';

class CertificateProvider with ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _certificates = [];
  String? _error;
  bool _isGenerating = false;

  // Program completion data - reuse dashboard logic
  List<dynamic> _syllabusWeeks = [];
  List<dynamic> _recentTasks = [];
  Map<String, dynamic> _stats = {};
  bool _canGenerateCertificate = false;

  // Getters
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get certificates => _certificates;
  String? get error => _error;
  bool get isGenerating => _isGenerating;
  bool get canGenerateCertificate => _canGenerateCertificate;

  // Statistics
  int get totalCertificates => _certificates.length;
  int get activeCertificates =>
      _certificates.where((cert) => cert['issued_at'] != null).length;

  // Program info
  String get programName => 'Web Development Internship';

  // ✅ SYNC WITH DASHBOARD: Use same calculation logic
  double get completionPercentage {
    try {
      // Calculate based on actual completion data (same as dashboard)
      final totalWeeks = _syllabusWeeks.length;
      final completedWeeks = _getCompletedWeeksCount();

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

        // Weighted calculation: 70% weeks + 30% tasks (same as dashboard)
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

      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // ✅ Helper method to count completed weeks (same logic as dashboard)
  int _getCompletedWeeksCount() {
    try {
      return _syllabusWeeks.where((week) {
        final userProgress = week['user_progress'];
        if (userProgress == null || userProgress.isEmpty) return false;

        final progress = userProgress[0];
        return progress['status'] == 'completed';
      }).length;
    } catch (e) {
      return 0;
    }
  }

  // ✅ Check if can generate certificate
  bool get _canGenerateBasedOnProgress {
    final totalWeeks = _syllabusWeeks.length;
    final completedWeeks = _getCompletedWeeksCount();

    // Can generate if all weeks completed and reasonable task completion
    bool allWeeksCompleted = totalWeeks > 0 && completedWeeks == totalWeeks;
    bool tasksOk =
        _recentTasks.isEmpty ||
        (_recentTasks
                .where(
                  (t) => [
                    'completed',
                    'submitted',
                  ].contains(t['status']?.toString().toLowerCase()),
                )
                .length >=
            (_recentTasks.length * 0.8)); // 80% task completion

    return allWeeksCompleted && tasksOk;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setGenerating(bool generating) {
    _isGenerating = generating;
    notifyListeners();
  }

  // Load all certificates
  Future<void> loadCertificates() async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await CertificateService.getCertificates();

      if (response['success'] == true) {
        _certificates = List<Map<String, dynamic>>.from(
          response['data']['certificates'] ?? [],
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to load certificates');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ✅ Load program completion using dashboard data (same sources)
  Future<void> checkProgramCompletion(int programId) async {
    try {
      // Load dashboard data (same as DashboardProvider)
      final dashboardResponse = await DashboardService.getDashboardData();
      if (dashboardResponse['success'] == true) {
        _recentTasks = dashboardResponse['data']['recent_tasks'] ?? [];
        _stats = dashboardResponse['data']['stats'] ?? {};
      }

      // Load syllabus weeks (same as DashboardProvider)
      final weeksResponse = await DashboardService.getWeeks();
      if (weeksResponse['success'] == true) {
        _syllabusWeeks = weeksResponse['data']['weeks'] ?? [];
      }

      // Update can generate certificate status
      _canGenerateCertificate = _canGenerateBasedOnProgress;

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Generate certificate
  Future<bool> generateCertificate(int programId) async {
    try {
      _setGenerating(true);
      _setError(null);

      final response = await CertificateService.generateCertificate(programId);

      if (response['success'] == true) {
        // Add new certificate to list
        final newCertificate = response['data']['certificate'];
        _certificates.insert(0, newCertificate);
        _canGenerateCertificate = false; // Disable generation after success

        notifyListeners();
        return true;
      } else {
        throw Exception(
          response['message'] ?? 'Failed to generate certificate',
        );
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setGenerating(false);
    }
  }

  // Get certificate download URL
  String getCertificateDownloadUrl(int certificateId) {
    return CertificateService.getCertificateDownloadUrl(certificateId);
  }

  // Verify certificate
  Future<Map<String, dynamic>?> verifyCertificate(
    String certificateNumber,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await CertificateService.verifyCertificate(
        certificateNumber,
      );

      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(
          response['message'] ?? 'Certificate verification failed',
        );
      }
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  bool hasCertificateForProgram(int programId) {
    return _certificates.any((cert) => cert['program_id'] == programId);
  }

  Map<String, dynamic>? getCertificateForProgram(int programId) {
    try {
      return _certificates.firstWhere(
        (cert) => cert['program_id'] == programId,
      );
    } catch (e) {
      return null;
    }
  }

  String formatCertificateDate(String? dateStr) {
    if (dateStr == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Clear data (for logout)
  void clearData() {
    _certificates = [];
    _syllabusWeeks = [];
    _recentTasks = [];
    _stats = {};
    _canGenerateCertificate = false;
    _isLoading = false;
    _isGenerating = false;
    _error = null;
    notifyListeners();
  }
}
