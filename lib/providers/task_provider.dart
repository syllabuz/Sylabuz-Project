import 'package:flutter/material.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _tasks = [];
  List<dynamic> _assignedTasks = [];
  List<dynamic> _createdTasks = [];
  String? _error;
  String _currentFilter = 'all'; // all, pending, submitted, completed
  
  // Getters
  bool get isLoading => _isLoading;
  List<dynamic> get tasks => _tasks;
  List<dynamic> get assignedTasks => _assignedTasks;
  List<dynamic> get createdTasks => _createdTasks;
  String? get error => _error;
  String get currentFilter => _currentFilter;
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    print('🔄 TaskProvider loading: $loading');
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    print('❌ TaskProvider error: $error');
    notifyListeners();
  }
  
  Future<void> loadTasks() async {
    try {
      print('🚀 TaskProvider: Starting loadTasks()...');
      _setLoading(true);
      _setError(null);
      
      print('📡 TaskProvider: Calling TaskService.getAssignedTasks()...');
      final response = await TaskService.getAssignedTasks();
      
      print('📥 TaskProvider: API Response: $response');
      
      if (response['success'] == true) {
        print('✅ TaskProvider: API call successful');
        
        final tasksData = response['data'];
        print('📋 TaskProvider: Tasks data: $tasksData');
        
        if (tasksData != null && tasksData['tasks'] != null) {
          _assignedTasks = List<dynamic>.from(tasksData['tasks']);
          print('📊 TaskProvider: Found ${_assignedTasks.length} assigned tasks');
          
          // Print each task for debugging
          for (int i = 0; i < _assignedTasks.length; i++) {
            print('📝 Task $i: ${_assignedTasks[i]}');
          }
        } else {
          _assignedTasks = [];
          print('📭 TaskProvider: No tasks found in response data');
        }
        
        _tasks = List.from(_assignedTasks);
        _filterTasks();
        print('🎯 TaskProvider: Final filtered tasks count: ${_tasks.length}');
      } else {
        final errorMsg = response['message'] ?? 'Failed to load tasks';
        print('❌ TaskProvider: API returned error: $errorMsg');
        _setError(errorMsg);
      }
    } catch (e) {
      print('💥 TaskProvider: Exception occurred: $e');
      print('📍 TaskProvider: Exception type: ${e.runtimeType}');
      _setError(e.toString());
    } finally {
      _setLoading(false);
      print('🏁 TaskProvider: loadTasks() completed');
    }
  }
  
  void setFilter(String filter) {
    print('🔍 TaskProvider: Setting filter to: $filter');
    _currentFilter = filter;
    _filterTasks();
    notifyListeners();
  }
  
  void _filterTasks() {
    print('🔍 TaskProvider: Filtering tasks with filter: $_currentFilter');
    print('📊 TaskProvider: Total assigned tasks: ${_assignedTasks.length}');
    
    if (_currentFilter == 'all') {
      _tasks = List.from(_assignedTasks);
    } else {
      _tasks = _assignedTasks.where((task) {
        final taskStatus = task['status'];
        print('🏷️ Task status: $taskStatus, Filter: $_currentFilter');
        return taskStatus == _currentFilter;
      }).toList();
    }
    
    print('✅ TaskProvider: Filtered tasks count: ${_tasks.length}');
  }
  
  Future<bool> submitTask(int taskId, String description, String? filePath) async {
    try {
      print('📤 TaskProvider: Submitting task $taskId...');
      _setLoading(true);
      
      final response = await TaskService.submitTask(taskId, description, filePath);
      print('📥 TaskProvider: Submit response: $response');
      
      if (response['success'] == true) {
        print('✅ TaskProvider: Task submitted successfully');
        await loadTasks(); // Refresh tasks
        return true;
      } else {
        final errorMsg = response['message'] ?? 'Failed to submit task';
        print('❌ TaskProvider: Submit failed: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e) {
      print('💥 TaskProvider: Submit exception: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper methods with debug info
  List<dynamic> get pendingTasks {
    final pending = _assignedTasks.where((task) => task['status'] == 'pending').toList();
    print('🟡 TaskProvider: Pending tasks count: ${pending.length}');
    return pending;
  }
  
  List<dynamic> get submittedTasks {
    final submitted = _assignedTasks.where((task) => task['status'] == 'submitted').toList();
    print('🔵 TaskProvider: Submitted tasks count: ${submitted.length}');
    return submitted;
  }
  
  List<dynamic> get completedTasks {
    final completed = _assignedTasks.where((task) => 
      task['status'] == 'completed' || task['status'] == 'reviewed'
    ).toList();
    print('🟢 TaskProvider: Completed tasks count: ${completed.length}');
    return completed;
  }
  
  List<dynamic> get overdueTasks {
    final now = DateTime.now();
    final overdue = _assignedTasks.where((task) {
      try {
        final deadline = DateTime.parse(task['deadline']);
        final isOverdue = deadline.isBefore(now) && 
               (task['status'] == 'pending' || task['status'] == 'submitted');
        return isOverdue;
      } catch (e) {
        return false;
      }
    }).toList();
    print('🔴 TaskProvider: Overdue tasks count: ${overdue.length}');
    return overdue;
  }
}



