import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../services/task_service.dart';
import 'submit_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _taskDetail;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTaskDetail();
  }

  Future<void> _loadTaskDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await TaskService.getTaskDetail(widget.task['id']);

      if (response['success'] == true) {
        setState(() {
          _taskDetail = response['data'];
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load task detail';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = _taskDetail ?? widget.task;

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          'Task Detail',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (task['status'] == 'pending')
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubmitTaskScreen(task: task),
                  ),
                ).then((_) => _loadTaskDetail()); // Refresh after submit
              },
              child: Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitThreeBounce(color: Color(0xFF2196F3), size: 30),
            SizedBox(height: 16),
            Text(
              'Loading task details...',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 64),
            SizedBox(height: 16),
            Text(
              'Failed to load task details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadTaskDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2196F3),
              ),
              child: Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final task = _taskDetail ?? widget.task;

    return RefreshIndicator(
      onRefresh: _loadTaskDetail,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Header Card
            _buildTaskHeader(task),
            SizedBox(height: 16),

            // Task Info Card
            _buildTaskInfo(task),
            SizedBox(height: 16),

            // Task Description Card
            _buildTaskDescription(task),
            SizedBox(height: 16),

            // Submissions Section (if available)
            if (task['submissions'] != null && task['submissions'].isNotEmpty)
              _buildSubmissionsSection(task),

            // Submit Button (for pending tasks)
            if (task['status'] == 'pending') _buildSubmitButton(task),

            SizedBox(height: 100), // Bottom spacing
          ],
        ),
      ),
    );
  }

  Widget _buildTaskHeader(Map<String, dynamic> task) {
    final status = task['status'] ?? 'pending';
    final priority = task['priority'] ?? 'medium';
    final title = task['title'] ?? 'Unknown Task';

    Color getStatusColor() {
      switch (status) {
        case 'completed':
        case 'reviewed':
          return Colors.green;
        case 'submitted':
          return Colors.blue;
        case 'pending':
        default:
          return Colors.orange;
      }
    }

    Color getPriorityColor() {
      switch (priority) {
        case 'high':
          return Colors.red;
        case 'medium':
          return Colors.orange;
        case 'low':
        default:
          return Colors.green;
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status & Priority Row
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: getStatusColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: getStatusColor(),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: getPriorityColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag, size: 14, color: getPriorityColor()),
                    SizedBox(width: 4),
                    Text(
                      '$priority PRIORITY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: getPriorityColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Task Title
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInfo(Map<String, dynamic> task) {
    final creator = task['creator'];
    final createdAt = task['created_at'];
    final deadline = task['deadline'];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),

          // Creator Info
          if (creator != null) ...[
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Created by',
              value: creator['full_name'] ?? 'Unknown',
              iconColor: Color(0xFF2196F3),
            ),
            SizedBox(height: 12),
          ],

          // Created Date
          if (createdAt != null)
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Created on',
              value: _formatDate(createdAt),
              iconColor: Colors.grey[600]!,
            ),
          SizedBox(height: 12),

          // Deadline
          _buildDeadlineRow(deadline),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlineRow(String? deadline) {
    if (deadline == null) {
      return _buildInfoRow(
        icon: Icons.schedule_outlined,
        label: 'Deadline',
        value: 'No deadline set',
        iconColor: Colors.grey[600]!,
      );
    }

    try {
      final deadlineDate = DateTime.parse(deadline);
      final now = DateTime.now();
      final difference = deadlineDate.difference(now);

      bool isOverdue = deadlineDate.isBefore(now);
      String timeLeft;
      Color deadlineColor;

      if (isOverdue) {
        timeLeft = 'Overdue';
        deadlineColor = Colors.red;
      } else if (difference.inDays > 0) {
        timeLeft = '${difference.inDays} days left';
        deadlineColor = difference.inDays <= 3 ? Colors.orange : Colors.green;
      } else if (difference.inHours > 0) {
        timeLeft = '${difference.inHours} hours left';
        deadlineColor = Colors.orange;
      } else if (difference.inMinutes > 0) {
        timeLeft = '${difference.inMinutes} minutes left';
        deadlineColor = Colors.red;
      } else {
        timeLeft = 'Due now';
        deadlineColor = Colors.red;
      }

      return Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: deadlineColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isOverdue ? Icons.warning_outlined : Icons.schedule_outlined,
              color: deadlineColor,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deadline',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  _formatDate(deadline),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  timeLeft,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: deadlineColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } catch (e) {
      return _buildInfoRow(
        icon: Icons.schedule_outlined,
        label: 'Deadline',
        value: 'Invalid date format',
        iconColor: Colors.grey[600]!,
      );
    }
  }

  Widget _buildTaskDescription(Map<String, dynamic> task) {
    final description = task['description'] ?? 'No description provided.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: Color(0xFF2196F3),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Task Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsSection(Map<String, dynamic> task) {
    final submissions = task['submissions'] as List<dynamic>;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.upload_outlined, color: Color(0xFF2196F3), size: 20),
              SizedBox(width: 8),
              Text(
                'Submissions (${submissions.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          ...submissions
              .map((submission) => _buildSubmissionCard(submission))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(Map<String, dynamic> submission) {
    final submittedAt = submission['created_at'];
    final description = submission['description'] ?? '';
    final filePath = submission['file_path'];
    final feedback = submission['feedback'];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Submission header
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text(
                'Submitted on ${_formatDate(submittedAt)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          if (description.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],

          if (filePath != null) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.attach_file, size: 16, color: Color(0xFF2196F3)),
                  SizedBox(width: 4),
                  Text(
                    'File attached',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (feedback != null && feedback.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.feedback_outlined,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    feedback,
                    style: TextStyle(fontSize: 13, color: Colors.blue[800]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton(Map<String, dynamic> task) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          return ElevatedButton(
            onPressed:
                provider.isLoading
                    ? null
                    : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmitTaskScreen(task: task),
                        ),
                      ).then((_) => _loadTaskDetail()); // Refresh after submit
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child:
                provider.isLoading
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Processing...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Submit This Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          );
        },
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy • HH:mm').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }
}
