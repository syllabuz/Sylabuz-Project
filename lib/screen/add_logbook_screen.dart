import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../providers/logbook_provider.dart';

class AddLogbookScreen extends StatefulWidget {
  final Map<String, dynamic>? entryToEdit;

  const AddLogbookScreen({Key? key, this.entryToEdit}) : super(key: key);

  @override
  _AddLogbookScreenState createState() => _AddLogbookScreenState();
}

class _AddLogbookScreenState extends State<AddLogbookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _attachmentPath;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.entryToEdit != null;

    if (_isEditing) {
      _descriptionController.text = widget.entryToEdit!['description'] ?? '';
      _selectedDate = DateTime.parse(widget.entryToEdit!['date']);
      _attachmentPath = widget.entryToEdit!['attachment_path'];
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Entry' : 'Add Logbook Entry',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2196F3),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Consumer<LogbookProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Guidelines Card
                  _buildGuidelinesCard(),

                  SizedBox(height: 20),

                  // Date Selection
                  _buildDateSelection(),

                  SizedBox(height: 20),

                  // Description Field
                  _buildDescriptionField(),

                  SizedBox(height: 20),

                  // File Attachment (Optional)
                  _buildAttachmentSection(),

                  SizedBox(height: 32),

                  // Submit Button
                  _buildSubmitButton(provider),

                  // Error Message
                  if (provider.error != null) ...[
                    SizedBox(height: 16),
                    _buildErrorMessage(provider.error!),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuidelinesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF2196F3), size: 20),
                SizedBox(width: 8),
                Text(
                  'Logbook Guidelines',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '• Document your daily activities and learning progress\n'
              '• Include challenges faced and how you solved them\n'
              '• Mention any new skills or knowledge gained\n'
              '• Be specific about tasks completed\n'
              '• Add photos or files if relevant',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            InkWell(
              onTap: _showDatePicker,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Color(0xFF2196F3)),
                    SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText:
                    'Describe your daily activities, what you learned, challenges faced, etc...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF2196F3)),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please describe your daily activities';
                }
                if (value.trim().length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attachment (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),

            if (_attachmentPath == null) ...[
              // Upload area
              InkWell(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Tap to add photo or document',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'PNG, JPG, PDF, DOC (max 10MB)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // File preview
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF2196F3).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(_attachmentPath!),
                      color: Color(0xFF2196F3),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getFileName(_attachmentPath!),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'File attached',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _attachmentPath = null;
                        });
                      },
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8),

              // Change file button
              TextButton.icon(
                onPressed: _pickFile,
                icon: Icon(Icons.swap_horiz, size: 16),
                label: Text('Change File'),
                style: TextButton.styleFrom(foregroundColor: Color(0xFF2196F3)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(LogbookProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: provider.isCreating ? null : _submitEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child:
            provider.isCreating
                ? SpinKitThreeBounce(color: Colors.white, size: 20.0)
                : Text(
                  _isEditing ? 'Update Entry' : 'Save Entry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF2196F3),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _pickFile() async {
    // File picker implementation
    // For now, simulate file selection
    setState(() {
      _attachmentPath = 'sample_document.pdf';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'File picker will be implemented with file_picker package',
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  IconData _getFileIcon(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.attach_file;
    }
  }

  String _getFileName(String filePath) {
    return filePath.split('/').last;
  }

  void _submitEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<LogbookProvider>(context, listen: false);
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    bool success;
    if (_isEditing) {
      success = await provider.updateLogbookEntry(
        entryId: widget.entryToEdit!['id'],
        date: dateString,
        description: _descriptionController.text.trim(),
        attachmentPath: _attachmentPath,
      );
    } else {
      success = await provider.createLogbookEntry(
        date: dateString,
        description: _descriptionController.text.trim(),
        attachmentPath: _attachmentPath,
      );
    }

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Entry updated successfully!'
                : 'Entry added successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
