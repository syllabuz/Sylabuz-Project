// lib/screen/certificate_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/certificate_provider.dart';

class CertificateDetailScreen extends StatelessWidget {
  final Map<String, dynamic> certificate;

  const CertificateDetailScreen({Key? key, required this.certificate})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final issuedDate = DateTime.parse(certificate['issued_at']).toLocal();
    final skillsCompleted = List<Map<String, dynamic>>.from(
      certificate['skills_completed'] ?? [],
    );

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Certificate Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2196F3),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: () => _downloadCertificate(context),
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareCertificate(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Certificate Preview Card
            _buildCertificatePreview(),

            SizedBox(height: 20),

            // Certificate Information
            _buildCertificateInfo(issuedDate),

            SizedBox(height: 20),

            // Skills Completed
            if (skillsCompleted.isNotEmpty) ...[
              _buildSkillsCompleted(skillsCompleted),
              SizedBox(height: 20),
            ],

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified, size: 48, color: Colors.green),
          SizedBox(height: 12),
          Text(
            'Certificate of Completion',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            certificate['program']?['name'] ?? 'Program',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF2196F3),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '#${certificate['certificate_number']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateInfo(DateTime issuedDate) {
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
            'Certificate Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),

          _buildInfoRow(
            'Certificate Number',
            certificate['certificate_number'],
          ),
          _buildInfoRow('Program', certificate['program']?['name'] ?? 'N/A'),
          _buildInfoRow(
            'Issued Date',
            DateFormat('dd MMMM yyyy').format(issuedDate),
          ),
          _buildInfoRow('Status', 'Valid', isStatus: true),

          SizedBox(height: 16),

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This certificate is digitally verified and can be authenticated using the certificate number.',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(': ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Expanded(
            child:
                isStatus
                    ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCompleted(List<Map<String, dynamic>> skills) {
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
            'Skills & Weeks Completed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),

          ...skills.map((skill) => _buildSkillItem(skill)).toList(),
        ],
      ),
    );
  }

  Widget _buildSkillItem(Map<String, dynamic> skill) {
    final completedDate = DateTime.parse(skill['completed_at']).toLocal();

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'W${skill['week_number']}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill['title'] ?? 'Week ${skill['week_number']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Completed on ${DateFormat('dd MMM yyyy').format(completedDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _downloadCertificate(context),
            icon: Icon(Icons.download, color: Colors.white),
            label: Text(
              'Download Certificate',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _shareCertificate(context),
            icon: Icon(Icons.share, color: Color(0xFF2196F3)),
            label: Text(
              'Share Certificate',
              style: TextStyle(
                color: Color(0xFF2196F3),
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Color(0xFF2196F3)),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _downloadCertificate(BuildContext context) async {
    final provider = Provider.of<CertificateProvider>(context, listen: false);
    final downloadUrl = provider.getCertificateDownloadUrl(certificate['id']);

    try {
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch download URL';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download certificate: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareCertificate(BuildContext context) {
    final shareText = '''
🎓 I've successfully completed ${certificate['program']?['name'] ?? 'the program'}!

Certificate #${certificate['certificate_number']}
Issued: ${DateFormat('dd MMMM yyyy').format(DateTime.parse(certificate['issued_at']))}

Verify this certificate at: [Your verification URL]

#Certificate #Achievement #LearningJourney
''';

    // You can implement share functionality here
    // For example, using share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Share functionality - implement with share_plus package',
        ),
        action: SnackBarAction(
          label: 'Copy Text',
          onPressed: () {
            // Copy shareText to clipboard
          },
        ),
      ),
    );
  }
}
