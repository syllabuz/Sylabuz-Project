import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../providers/logbook_provider.dart';
import 'add_logbook_screen.dart';

class LogbookScreen extends StatefulWidget {
  @override
  _LogbookScreenState createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  @override
  void initState() {
    super.initState();
    _loadLogbookEntries();
  }

  void _loadLogbookEntries() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LogbookProvider>(context, listen: false).loadLogbookEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Daily Logbook',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2196F3),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddLogbookScreen()),
              ).then((_) {
                // Refresh when returning from add screen
                _loadLogbookEntries();
              });
            },
          ),
        ],
      ),
      body: Consumer<LogbookProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadLogbookEntries();
            },
            child: Column(
              children: [
                // Stats Header
                _buildStatsHeader(provider),

                // Entries List
                Expanded(child: _buildEntriesList(provider)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddLogbookScreen()),
          ).then((_) {
            _loadLogbookEntries();
          });
        },
        backgroundColor: Color(0xFF2196F3),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsHeader(LogbookProvider provider) {
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
              'Total Entries',
              provider.totalEntries.toString(),
              Icons.book,
              Color(0xFF2196F3),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'This Month',
              provider.thisMonthEntries.toString(),
              Icons.calendar_month,
              Color(0xFF4CAF50),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'This Week',
              provider.thisWeekEntries.length.toString(),
              Icons.date_range,
              Color(0xFFFF9800),
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

  Widget _buildEntriesList(LogbookProvider provider) {
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
              'Error loading logbook',
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
              onPressed: _loadLogbookEntries,
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

    if (provider.logbookEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No logbook entries yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start documenting your daily activities!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddLogbookScreen()),
                ).then((_) {
                  _loadLogbookEntries();
                });
              },
              child: Text('Add First Entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.logbookEntries.length,
      itemBuilder: (context, index) {
        final entry = provider.logbookEntries[index];
        return _buildLogbookCard(entry, provider);
      },
    );
  }

  Widget _buildLogbookCard(
    Map<String, dynamic> entry,
    LogbookProvider provider,
  ) {
    final entryDate = DateTime.parse(entry['date']);
    final isToday = _isToday(entryDate);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              isToday
                  ? BorderSide(color: Color(0xFF2196F3), width: 2)
                  : BorderSide.none,
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isToday ? Color(0xFF2196F3) : Colors.grey[600],
                      ),
                      SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, dd MMM yyyy').format(entryDate),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isToday ? Color(0xFF2196F3) : Colors.grey[700],
                        ),
                      ),
                      if (isToday)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    AddLogbookScreen(entryToEdit: entry),
                          ),
                        ).then((_) {
                          _loadLogbookEntries();
                        });
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(entry, provider);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Description
              Text(
                entry['description'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),

              // Attachment indicator
              if (entry['attachment_path'] != null) ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.attach_file, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      'Has attachment',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],

              // Timestamp
              SizedBox(height: 8),
              Text(
                'Added on ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(entry['created_at']).toLocal())}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showDeleteConfirmation(
    Map<String, dynamic> entry,
    LogbookProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Entry'),
            content: Text(
              'Are you sure you want to delete this logbook entry? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await provider.deleteLogbookEntry(
                    entry['id'],
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Entry deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete entry'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
