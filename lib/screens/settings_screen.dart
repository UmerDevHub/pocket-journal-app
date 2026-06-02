import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import 'privacy_policy_screen.dart';

/// Settings screen with theme toggle and export
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

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
          'Settings',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance section
          _buildSectionTitle('Appearance', isDarkMode),
          _buildCard(
            isDarkMode: isDarkMode,
            child: _buildThemeToggle(context, themeProvider, isDarkMode),
          ),
          const SizedBox(height: 24),
          
          // Data section
          _buildSectionTitle('Data', isDarkMode),
          _buildCard(
            isDarkMode: isDarkMode,
            child: Column(
              children: [
                _buildExportTile(context, isDarkMode),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // About section
          _buildSectionTitle('About', isDarkMode),
          _buildCard(
            isDarkMode: isDarkMode,
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Version',
                  subtitle: '1.0.0',
                  isDarkMode: isDarkMode,
                ),
                Divider(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                  height: 1,
                ),
                _buildInfoTile(
                  icon: Icons.code_rounded,
                  title: 'Made with',
                  subtitle: 'Flutter & ❤️',
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Legal section
          _buildSectionTitle('Legal', isDarkMode),
          _buildCard(
            isDarkMode: isDarkMode,
            child: Column(
              children: [
                _buildPrivacyPolicyTile(context, isDarkMode),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          // Footer
          Center(
            child: Text(
              'Pocket Journal',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildCard({required bool isDarkMode, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider, bool isDarkMode) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.indigo.shade400, Colors.purple.shade400]
                : [Colors.amber.shade400, Colors.orange.shade400],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      title: Text(
        'Dark Mode',
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        isDarkMode ? 'Currently using dark theme' : 'Currently using light theme',
        style: GoogleFonts.outfit(
          fontSize: 13,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
      trailing: Switch.adaptive(
        value: isDarkMode,
        onChanged: (_) => themeProvider.toggleTheme(),
        activeColor: const Color(0xFF3B82F6),
      ),
    );
  }

  Widget _buildExportTile(BuildContext context, bool isDarkMode) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.cyan.shade400],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.download_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      title: Text(
        'Export Notes',
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        'Save all notes as a text file',
        style: GoogleFonts.outfit(
          fontSize: 13,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
      ),
      onTap: () => _exportNotes(context, isDarkMode),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDarkMode,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.outfit(
          fontSize: 13,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyTile(BuildContext context, bool isDarkMode) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.indigo.shade400],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.shield_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      title: Text(
        'Privacy Policy',
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        'How we protect your data',
        style: GoogleFonts.outfit(
          fontSize: 13,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
      ),
    );
  }

  Future<void> _exportNotes(BuildContext context, bool isDarkMode) async {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    
    try {
      final exportText = await notesProvider.exportNotes();
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final file = File('${directory.path}/pocket_journal_export_$timestamp.txt');
      await file.writeAsString(exportText);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes exported successfully!',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        file.path,
                        style: GoogleFonts.outfit(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Failed to export notes',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
