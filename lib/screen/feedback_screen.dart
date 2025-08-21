import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../providers/feedback_provider.dart';
import 'feedback_detail_screen.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFeedback();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final provider = Provider.of<FeedbackProvider>(context, listen: false);
        provider.setSelectedTab(_tabController.index);
        provider.loadAllFeedback();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadFeedback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedbackProvider>(
        context,
        listen: false,
      ).loadReceivedFeedback();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Mentor Feedback',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2196F3),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.feedback), text: 'Received'),
            Tab(icon: Icon(Icons.rate_review), text: 'Overview'),
          ],
        ),
      ),
      body: Consumer<FeedbackProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildReceivedFeedbackTab(provider),
              _buildOverviewTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReceivedFeedbackTab(FeedbackProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadReceivedFeedback();
      },
      child: Column(
        children: [
          // Stats Header
          _buildStatsHeader(provider),

          // Feedback List
          Expanded(child: _buildFeedbackList(provider)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(FeedbackProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadReceivedFeedback();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Performance Overview
            _buildPerformanceOverview(provider),

            SizedBox(height: 20),

            // Feedback Categories
            _buildFeedbackCategories(provider),

            SizedBox(height: 20),

            // Recent Feedback
            _buildRecentFeedback(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(FeedbackProvider provider) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Feedback',
              provider.totalFeedback.toString(),
              Icons.feedback,
              Color(0xFF2196F3),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Average Rating',
              provider.averageRating.toStringAsFixed(1),
              Icons.star,
              Color(0xFFFF9800),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'This Month',
              provider.thisMonthFeedback.toString(),
              Icons.calendar_month,
              Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackList(FeedbackProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: SpinKitFadingCircle(color: Color(0xFF2196F3), size: 50.0),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            SizedBox(height: 16),
            Text(
              'Error loading feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              provider.error!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadFeedback,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.receivedFeedback.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feedback_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No feedback yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Complete tasks and syllabus to receive feedback from mentors!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.receivedFeedback.length,
      itemBuilder: (context, index) {
        final feedback = provider.receivedFeedback[index];
        return _buildFeedbackCard(feedback);
      },
    );
  }

  // 🚀 FIXED: _buildFeedbackCard method with proper structure
  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    final rating = feedback['rating']?.toDouble() ?? 0.0;
    final feedbackType = feedback['feedback_type'] ?? 'general';
    final createdAt = DateTime.parse(feedback['created_at']);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FeedbackDetailScreen(feedback: feedback),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with mentor info and rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _getFeedbackTypeIcon(feedbackType),
                        SizedBox(width: 8),
                        Text(
                          _getFeedbackTypeLabel(feedbackType),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Mentor name
                Text(
                  feedback['from_user']?['full_name'] ?? 'Mentor',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),

                SizedBox(height: 8),

                // Feedback comment
                Text(
                  feedback['comment'] ?? '',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 8),

                // Date
                Text(
                  DateFormat('dd MMM yyyy').format(createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
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

  Widget _buildPerformanceOverview(FeedbackProvider provider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),

          // Average Rating Display
          Row(
            children: [
              Text(
                'Average Rating: ',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < provider.averageRating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${provider.averageRating.toStringAsFixed(1)}/5.0',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Progress Indicator
          LinearProgressIndicator(
            value: provider.averageRating / 5.0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              provider.averageRating >= 4.0
                  ? Colors.green
                  : provider.averageRating >= 3.0
                  ? Colors.orange
                  : Colors.red,
            ),
          ),

          SizedBox(height: 12),

          // Performance Text
          Text(
            _getPerformanceText(provider.averageRating),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCategories(FeedbackProvider provider) {
    // Count feedback by category
    int taskCount =
        provider.receivedFeedback
            .where((f) => f['feedback_type'] == 'task')
            .length;
    int syllabusCount =
        provider.receivedFeedback
            .where(
              (f) =>
                  f['feedback_type'] == 'week' ||
                  f['feedback_type'] == 'syllabus',
            )
            .length;
    int generalCount =
        provider.receivedFeedback
            .where((f) => f['feedback_type'] == 'general')
            .length;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feedback Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),

          // Category breakdown
          _buildCategoryItem(
            'Task Feedback',
            taskCount,
            Icons.assignment,
            Color(0xFF2196F3),
          ),
          SizedBox(height: 12),
          _buildCategoryItem(
            'Syllabus Feedback',
            syllabusCount,
            Icons.book,
            Color(0xFF4CAF50),
          ),
          SizedBox(height: 12),
          _buildCategoryItem(
            'General Feedback',
            generalCount,
            Icons.comment,
            Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentFeedback(FeedbackProvider provider) {
    // Get recent feedback (last 3)
    final recentFeedback = provider.receivedFeedback.take(3).toList();

    if (recentFeedback.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Recent Feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Icon(Icons.feedback_outlined, size: 48, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              'No recent feedback',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Feedback',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () {
                  _tabController.animateTo(0); // Switch to Received tab
                },
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Recent feedback list
          ...recentFeedback
              .map(
                (feedback) => Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _getFeedbackTypeIcon(
                            feedback['feedback_type'] ?? 'general',
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feedback['from_user']?['full_name'] ?? 'Mentor',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < (feedback['rating']?.toDouble() ?? 0.0)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        feedback['comment'] ?? '',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  String _getPerformanceText(double rating) {
    if (rating >= 4.5)
      return 'Excellent performance! Keep up the great work! 🌟';
    if (rating >= 4.0) return 'Great job! You\'re doing really well! 👏';
    if (rating >= 3.5) return 'Good work! There\'s room for improvement. 👍';
    if (rating >= 3.0)
      return 'Average performance. Focus on areas for improvement. 📈';
    if (rating >= 2.0)
      return 'Below average. Work harder on your tasks and syllabus. 💪';
    return 'Needs significant improvement. Don\'t give up! 🎯';
  }
}
