import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../providers/task_provider.dart';

class SubmitTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const SubmitTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  _SubmitTaskScreenState createState() => _SubmitTaskScreenState();
}

class _SubmitTaskScreenState extends State<SubmitTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  File? _selectedFile;
  String? _fileName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'txt',
          'zip',
          'rar',
          'jpg',
          'jpeg',
          'png',
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = File(result.files.first.path!);
          _fileName = result.files.first.name;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick file: ${e.toString()}');
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
  }

  Future<void> _submitTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if description is empty and no file selected
    if (_descriptionController.text.trim().isEmpty && _selectedFile == null) {
      _showErrorSnackBar('Please provide a description or attach a file');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      final success = await taskProvider.submitTask(
        widget.task['id'],
        _descriptionController.text.trim(),
        _selectedFile?.path,
      );

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorSnackBar(taskProvider.error ?? 'Failed to submit task');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green, size: 50),
              ),
              SizedBox(height: 20),
              Text(
                'Task Submitted!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your submission has been sent successfully. You will receive feedback soon.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to detail screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          'Submit Task',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Info Card
              _buildTaskInfoCard(),
              SizedBox(height: 20),

              // Description Section
              _buildDescriptionSection(),
              SizedBox(height: 20),

              // File Upload Section
              _buildFileUploadSection(),
              SizedBox(height: 20),

              // Guidelines Section
              _buildGuidelinesSection(),
              SizedBox(height: 30),

              // Submit Button
              _buildSubmitButton(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfoCard() {
    final task = widget.task;
    final title = task['title'] ?? 'Unknown Task';
    final deadline = task['deadline'];
    final priority = task['priority'] ?? 'medium';

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

    String getDeadlineText() {
      if (deadline == null) return 'No deadline';

      try {
        final deadlineDate = DateTime.parse(deadline);
        final now = DateTime.now();
        final difference = deadlineDate.difference(now);

        if (deadlineDate.isBefore(now)) {
          return 'Overdue';
        } else if (difference.inDays > 0) {
          return '${difference.inDays} days left';
        } else if (difference.inHours > 0) {
          return '${difference.inHours} hours left';
        } else if (difference.inMinutes > 0) {
          return '${difference.inMinutes} minutes left';
        } else {
          return 'Due now';
        }
      } catch (e) {
        return 'Invalid date';
      }
    }

    bool isOverdue = false;
    if (deadline != null) {
      try {
        final deadlineDate = DateTime.parse(deadline);
        isOverdue = deadlineDate.isBefore(DateTime.now());
      } catch (e) {
        // Invalid date
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
        border: isOverdue ? Border.all(color: Colors.red, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getPriorityColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priority.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: getPriorityColor(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isOverdue ? Icons.warning : Icons.schedule,
                size: 16,
                color: isOverdue ? Colors.red : Colors.grey[600],
              ),
              SizedBox(width: 6),
              Text(
                getDeadlineText(),
                style: TextStyle(
                  fontSize: 14,
                  color: isOverdue ? Colors.red : Colors.grey[600],
                  fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
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
                'Submission Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText:
                  'Describe your work, approach, challenges, or any notes you want to share...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF2196F3), width: 2),
              ),
              contentPadding: EdgeInsets.all(16),
            ),
            validator: (value) {
              // Optional validation - can be empty if file is provided
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadSection() {
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
              Icon(Icons.attach_file, color: Color(0xFF2196F3), size: 20),
              SizedBox(width: 8),
              Text(
                'File Attachment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '(Optional)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          if (_selectedFile == null) ...[
            // Upload Area
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFF2196F3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xFF2196F3).withOpacity(0.05),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: Color(0xFF2196F3),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Tap to select file',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'PDF, DOC, TXT, ZIP, or Images',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Selected File Display
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getFileIcon(_fileName!),
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fileName!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          _getFileSize(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _removeFile,
                    icon: Icon(Icons.close, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            // Change File Button
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF2196F3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 16, color: Color(0xFF2196F3)),
                    SizedBox(width: 8),
                    Text(
                      'Change File',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGuidelinesSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outlined, color: Colors.blue[600], size: 20),
              SizedBox(width: 8),
              Text(
                'Submission Guidelines',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildGuidelineItem('Provide a clear description of your work'),
          _buildGuidelineItem(
            'Include any challenges you faced and how you solved them',
          ),
          _buildGuidelineItem('Attach relevant files (max 50MB per file)'),
          _buildGuidelineItem(
            'Make sure your submission addresses all task requirements',
          ),
          _buildGuidelineItem('You can resubmit if needed before the deadline'),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.blue[600],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2196F3),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            _isSubmitting
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Submitting...',
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
                    Icon(Icons.send, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Submit Task',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.archive;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileSize() {
    if (_selectedFile == null) return '';

    try {
      final bytes = _selectedFile!.lengthSync();
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }
}
