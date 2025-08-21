import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedbackDetailScreen extends StatelessWidget {
  final Map<String, dynamic> feedback;

  const FeedbackDetailScreen({Key? key, required this.feedback})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rating = feedback['rating']?.toDouble() ?? 0.0;
    final feedbackType = feedback['feedback_type'] ?? 'general';
    final createdAt = DateTime.parse(feedback['created_at']);

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Feedback Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2196F3),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(rating, feedbackType, createdAt),

            SizedBox(height: 16),

            // Mentor Info Card
            _buildMentorCard(),

            SizedBox(height: 16),

            // Comment Card
            _buildCommentCard(),

            // Related Content Card
            if (feedback['task'] != null ||
                feedback['syllabus_week'] != null) ...[
              SizedBox(height: 16),
              _buildRelatedContentCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    double rating,
    String feedbackType,
    DateTime createdAt,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Rating Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '/ 100',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Icon(
                  index < rating / 20 ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
            ),

            SizedBox(height: 16),

            // Feedback Type Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getFeedbackTypeColor(feedbackType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getFeedbackTypeColor(feedbackType).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getFeedbackTypeIcon(feedbackType),
                  SizedBox(width: 6),
                  Text(
                    _getFeedbackTypeLabel(feedbackType),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getFeedbackTypeColor(feedbackType),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Date
            Text(
              'Received on ${DateFormat('EEEE, dd MMMM yyyy \'at\' HH:mm').format(createdAt)}',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMentorCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF2196F3),
              child: Text(
                feedback['from_user']?['full_name']?.substring(0, 1) ?? 'M',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feedback['from_user']?['full_name'] ?? 'Mentor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    feedback['from_user']?['email'] ?? 'mentor@syllabuz.com',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.verified, color: Color(0xFF4CAF50), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard() {
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
                Icon(Icons.format_quote, color: Color(0xFF2196F3), size: 20),
                SizedBox(width: 8),
                Text(
                  'Feedback Comment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                feedback['comment'] ?? 'No comment provided.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedContentCard() {
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
                Icon(Icons.link, color: Color(0xFF2196F3), size: 20),
                SizedBox(width: 8),
                Text(
                  'Related Content',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Task Info
            if (feedback['task'] != null) ...[
              Container(
                width: double.infinity,
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
                          Icons.assignment,
                          color: Colors.blue[700],
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Task Feedback',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      feedback['task']['title'] ?? 'Task Title',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (feedback['task']['description'] != null) ...[
                      SizedBox(height: 4),
                      Text(
                        feedback['task']['description'],
                        style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Week/Syllabus Info
            if (feedback['syllabus_week'] != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.book, color: Colors.green[700], size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Syllabus Feedback',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      feedback['syllabus_week']['title'] ?? 'Week Title',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (feedback['syllabus_week']['description'] != null) ...[
                      SizedBox(height: 4),
                      Text(
                        feedback['syllabus_week']['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getFeedbackTypeIcon(String type) {
    switch (type) {
      case 'task':
        return Icon(Icons.assignment, color: Color(0xFF2196F3), size: 16);
      case 'week':
      case 'syllabus':
        return Icon(Icons.book, color: Color(0xFF4CAF50), size: 16);
      case 'general':
        return Icon(Icons.comment, color: Color(0xFFFF9800), size: 16);
      default:
        return Icon(Icons.feedback, color: Colors.grey[600], size: 16);
    }
  }

  String _getFeedbackTypeLabel(String type) {
    switch (type) {
      case 'task':
        return 'Task Feedback';
      case 'week':
      case 'syllabus':
        return 'Syllabus Feedback';
      case 'general':
        return 'General Feedback';
      default:
        return 'Feedback';
    }
  }

  Color _getFeedbackTypeColor(String type) {
    switch (type) {
      case 'task':
        return Color(0xFF2196F3);
      case 'week':
      case 'syllabus':
        return Color(0xFF4CAF50);
      case 'general':
        return Color(0xFFFF9800);
      default:
        return Colors.grey[600]!;
    }
  }
}
