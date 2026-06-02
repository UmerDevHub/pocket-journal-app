import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Privacy Policy screen for Play Store compliance
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '🔒 Your Privacy Matters',
              content: 'Pocket Journal is designed with your privacy as the top priority. '
                  'This app operates entirely offline and stores all your data locally on your device.',
              isDarkMode: isDarkMode,
            ),
            _buildSection(
              title: 'Data Collection',
              content: 'We do NOT collect any personal information.\n\n'
                  '• No account or login required\n'
                  '• No analytics or tracking\n'
                  '• No internet connection required\n'
                  '• No third-party services\n'
                  '• No advertising',
              isDarkMode: isDarkMode,
            ),
            _buildSection(
              title: 'Data Storage',
              content: 'All your notes are stored locally on your device using SQLite database. '
                  'Your data never leaves your device and is not accessible to us or anyone else.',
              isDarkMode: isDarkMode,
            ),
            _buildSection(
              title: 'Data Security',
              content: 'Your notes are protected by your device\'s built-in security features. '
                  'When you delete the app, all your data is permanently removed from your device.',
              isDarkMode: isDarkMode,
            ),
            _buildSection(
              title: 'Permissions',
              content: 'This app requires minimal permissions:\n\n'
                  '• Storage: To save and read your notes locally\n\n'
                  'No other permissions are required.',
              isDarkMode: isDarkMode,
            ),
            _buildSection(
              title: 'Children\'s Privacy',
              content: 'This app does not collect any data and is safe for users of all ages.',
              isDarkMode: isDarkMode,
            ),
            _buildSection(
              title: 'Changes to This Policy',
              content: 'We may update this privacy policy from time to time. Any changes will be '
                  'reflected in the app update.',
              isDarkMode: isDarkMode,
            ),
            _buildSection(
              title: 'Contact',
              content: 'If you have any questions about this privacy policy, please contact us at:\n\n'
                  'support@pocketjournal.app',
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Last updated: January 2026',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 15,
              height: 1.6,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
