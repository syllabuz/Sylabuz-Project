// lib/screen/certificate_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/certificate_provider.dart';
import 'certificate_detail_screen.dart';

class CertificateScreen extends StatefulWidget {
  @override
  _CertificateScreenState createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final int _programId = 1; // Get from dashboard or pass as parameter

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CertificateProvider>(context, listen: false);
      provider.loadCertificates();
      provider.checkProgramCompletion(_programId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'My Certificates',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2196F3),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.verified_user, color: Colors.white),
            onPressed: () => _showVerificationDialog(),
          ),
        ],
      ),
      body: Consumer<CertificateProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadCertificates();
              await provider.checkProgramCompletion(_programId);
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Program Progress Overview
                  _buildProgressOverview(provider),

                  SizedBox(height: 20),

                  // Certificate Generation Section
                  _buildCertificateGeneration(provider),

                  SizedBox(height: 20),

                  // Certificates Gallery
                  _buildCertificatesGallery(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressOverview(CertificateProvider provider) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2196F3).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.school, color: Colors.white, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Certificate Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      provider.programName,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Progress Stats
          Row(
            children: [
              Expanded(
                child: _buildProgressStat(
                  'Completion',
                  '${provider.completionPercentage.toInt()}%',
                  Icons.trending_up,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildProgressStat(
                  'Certificates',
                  '${provider.totalCertificates}',
                  Icons.card_membership,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overall Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: provider.completionPercentage / 100,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCertificateGeneration(CertificateProvider provider) {
    final hasExistingCertificate = provider.hasCertificateForProgram(
      _programId,
    );

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
            children: [
              Icon(
                hasExistingCertificate ? Icons.verified : Icons.pending_actions,
                color:
                    hasExistingCertificate ? Colors.green : Color(0xFF2196F3),
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasExistingCertificate
                          ? 'Certificate Ready'
                          : 'Certificate Generation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      hasExistingCertificate
                          ? 'Your certificate is ready for download'
                          : provider.canGenerateCertificate
                          ? 'You can now generate your certificate'
                          : 'Complete the program to generate certificate',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          if (hasExistingCertificate) ...[
            // Download Certificate Button
            _buildDownloadButton(provider),
          ] else if (provider.canGenerateCertificate) ...[
            // Generate Certificate Button
            _buildGenerateButton(provider),
          ] else ...[
            // Requirements Display
            _buildRequirements(provider),
          ],
        ],
      ),
    );
  }

  Widget _buildDownloadButton(CertificateProvider provider) {
    final certificate = provider.getCertificateForProgram(_programId);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _downloadCertificate(certificate?['id']),
        icon: Icon(Icons.download, color: Colors.white),
        label: Text(
          'Download Certificate',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildGenerateButton(CertificateProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
            provider.isGenerating ? null : () => _generateCertificate(provider),
        icon:
            provider.isGenerating
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : Icon(Icons.card_membership, color: Colors.white),
        label: Text(
          provider.isGenerating ? 'Generating...' : 'Generate Certificate',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2196F3),
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildRequirements(CertificateProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requirements to generate certificate:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        _buildRequirementItem('Complete all syllabus weeks', false),
        _buildRequirementItem('Submit all tasks', false),
        _buildRequirementItem('Maintain regular logbook entries', false),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.orange, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Complete ${(100 - provider.completionPercentage).toInt()}% more to unlock certificate generation',
                  style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool completed) {
    return Row(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? Colors.green : Colors.grey,
          size: 16,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: completed ? Colors.green : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCertificatesGallery(CertificateProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Certificates',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16),

        if (provider.isLoading) ...[
          Center(
            child: SpinKitFadingCircle(color: Color(0xFF2196F3), size: 50.0),
          ),
        ] else if (provider.error != null) ...[
          _buildErrorState(provider),
        ] else if (provider.certificates.isEmpty) ...[
          _buildEmptyState(),
        ] else ...[
          _buildCertificatesList(provider),
        ],
      ],
    );
  }

  Widget _buildCertificatesList(CertificateProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: provider.certificates.length,
      itemBuilder: (context, index) {
        final certificate = provider.certificates[index];
        return _buildCertificateCard(certificate, provider);
      },
    );
  }

  Widget _buildCertificateCard(
    Map<String, dynamic> certificate,
    CertificateProvider provider,
  ) {
    final issuedDate = DateTime.parse(certificate['issued_at']).toLocal();

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          CertificateDetailScreen(certificate: certificate),
                ),
              ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.verified,
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
                            certificate['program']?['name'] ?? 'Certificate',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Certificate #${certificate['certificate_number']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _downloadCertificate(certificate['id']),
                      icon: Icon(Icons.download, color: Color(0xFF2196F3)),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Issued on ${DateFormat('dd MMM yyyy').format(issuedDate)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 40),
          Icon(Icons.card_membership, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No certificates yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Complete the program to earn your first certificate!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildErrorState(CertificateProvider provider) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          SizedBox(height: 16),
          Text(
            'Error loading certificates',
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
            onPressed: _loadData,
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

  void _generateCertificate(CertificateProvider provider) async {
    final success = await provider.generateCertificate(_programId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Certificate generated successfully!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Download',
            textColor: Colors.white,
            onPressed: () {
              final certificate = provider.getCertificateForProgram(_programId);
              if (certificate != null) {
                _downloadCertificate(certificate['id']);
              }
            },
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to generate certificate'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _downloadCertificate(int? certificateId) async {
    if (certificateId == null) return;

    final provider = Provider.of<CertificateProvider>(context, listen: false);
    final downloadUrl = provider.getCertificateDownloadUrl(certificateId);

    try {
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch download URL';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download certificate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showVerificationDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Verify Certificate'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter certificate number to verify authenticity:',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Certificate Number',
                    hintText: 'CERT-XXXXXXXXXX',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    await _verifyCertificate(controller.text.trim());
                  }
                },
                child: Text('Verify'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _verifyCertificate(String certificateNumber) async {
    final provider = Provider.of<CertificateProvider>(context, listen: false);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Verifying certificate...'),
                ],
              ),
            ),
          ),
    );

    final result = await provider.verifyCertificate(certificateNumber);

    // Dismiss loading dialog
    Navigator.pop(context);

    // Show result dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  result != null ? Icons.verified : Icons.error,
                  color: result != null ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  result != null ? 'Certificate Valid' : 'Invalid Certificate',
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result != null) ...[
                  Text(
                    'Certificate Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Program: ${result['program']?['name'] ?? 'N/A'}'),
                  Text('Student: ${result['user']?['full_name'] ?? 'N/A'}'),
                  Text(
                    'Issued: ${result['issued_at'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(result['issued_at'])) : 'N/A'}',
                  ),
                ] else ...[
                  Text(
                    'The certificate number you entered is not valid or does not exist in our records.',
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }
}
