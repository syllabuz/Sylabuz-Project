import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/task_provider.dart';
import 'task_detail_screen.dart';
import 'submit_task_screen.dart';
import 'dashboard_screen.dart';
import 'syllabus_screen.dart';
import 'logbook_screen.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load tasks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          'Tasks',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return Column(
            children: [
              // Blue Header Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(color: Color(0xFF1976D2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'My Tasks ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.assignment, color: Colors.white, size: 20),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Track your assignments and deadlines',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats Row
              _buildStatsRow(taskProvider),

              // Filter Tabs
              _buildFilterTabs(taskProvider),

              // Content Area
              Expanded(child: _buildContent(taskProvider)),
            ],
          );
        },
      ),

      // Bottom Navigation
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildStatsRow(TaskProvider provider) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            'Pending',
            provider.pendingTasks.length.toString(),
            Colors.orange,
          ),
          _buildStatItem(
            'Submitted',
            provider.submittedTasks.length.toString(),
            Colors.blue,
          ),
          _buildStatItem(
            'Completed',
            provider.completedTasks.length.toString(),
            Colors.green,
          ),
          _buildStatItem(
            'Overdue',
            provider.overdueTasks.length.toString(),
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(TaskProvider provider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          switch (index) {
            case 0:
              provider.setFilter('all');
              break;
            case 1:
              provider.setFilter('pending');
              break;
            case 2:
              provider.setFilter('submitted');
              break;
            case 3:
              provider.setFilter('completed');
              break;
          }
        },
        tabs: [
          Tab(text: 'All'),
          Tab(text: 'Pending'),
          Tab(text: 'Submitted'),
          Tab(text: 'Completed'),
        ],
        labelColor: Color(0xFF2196F3),
        unselectedLabelColor: Colors.grey[600],
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Color(0xFF2196F3).withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildContent(TaskProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitThreeBounce(color: Color(0xFF2196F3), size: 30),
            SizedBox(height: 16),
            Text(
              'Loading tasks...',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 64),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                provider.loadTasks();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2196F3),
              ),
              child: Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (provider.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No tasks available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later for new assignments',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadTasks();
      },
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        itemCount: provider.tasks.length,
        itemBuilder: (context, index) {
          final task = provider.tasks[index];
          return _buildTaskCard(task);
        },
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final status = task['status'] ?? 'pending';
    final title = task['title'] ?? 'Unknown Task';
    final description = task['description'] ?? '';
    final deadline = task['deadline'];
    final priority = task['priority'] ?? 'medium';
    final creator = task['creator'];

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

    bool isOverdue = false;
    String deadlineText = 'No deadline';

    if (deadline != null) {
      try {
        final deadlineDate = DateTime.parse(deadline);
        final now = DateTime.now();
        final difference = deadlineDate.difference(now);

        isOverdue =
            deadlineDate.isBefore(now) &&
            (status == 'pending' || status == 'submitted');

        if (difference.inDays > 0) {
          deadlineText = '${difference.inDays} days left';
        } else if (difference.inHours > 0) {
          deadlineText = '${difference.inHours} hours left';
        } else if (difference.inMinutes > 0) {
          deadlineText = '${difference.inMinutes} minutes left';
        } else {
          deadlineText = isOverdue ? 'Overdue' : 'Due now';
        }
      } catch (e) {
        deadlineText = 'Invalid date';
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: isOverdue ? Border.all(color: Colors.red, width: 1) : null,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
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
              SizedBox(height: 8),

              // Description
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),

              // Footer Row
              Row(
                children: [
                  // Creator info
                  if (creator != null) ...[
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4),
                    Text(
                      creator['full_name'] ?? 'Unknown',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(width: 16),
                  ],

                  // Deadline
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: isOverdue ? Colors.red : Colors.grey[500],
                  ),
                  SizedBox(width: 4),
                  Text(
                    deadlineText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                      fontWeight:
                          isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  Spacer(),

                  // Status badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),

              // Submit button for pending tasks
              if (status == 'pending') ...[
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmitTaskScreen(task: task),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Submit Task',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
            },
            child: _buildBottomNavItem(Icons.home, 'Dashboard', false),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SyllabusScreen()),
              );
            },
            child: _buildBottomNavItem(Icons.book, 'Syllabus', true),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TaskScreen()),
              );
            },
            child: _buildBottomNavItem(Icons.assignment, 'Tasks', false),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LogbookScreen()),
              );
            },
            child: _buildBottomNavItem(Icons.book_outlined, 'Logbook', false),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? Color(0xFF2196F3) : Colors.grey[600],
          size: 24,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Color(0xFF2196F3) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
