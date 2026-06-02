import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';

/// Bottom sheet with note actions (edit, delete, pin, share)
class NoteOptionsSheet extends StatelessWidget {
  final Note note;
  final NotesProvider notesProvider;
  final bool isDarkMode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteOptionsSheet({
    super.key,
    required this.note,
    required this.notesProvider,
    required this.isDarkMode,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Note title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _hexToColor(note.color),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    note.title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (note.isPinned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.push_pin_rounded, size: 14, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Pinned',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Divider(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
            height: 1,
          ),
          // Actions
          _buildOptionTile(
            context: context,
            icon: Icons.edit_rounded,
            label: 'Edit Note',
            color: const Color(0xFF3B82F6),
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          _buildOptionTile(
            context: context,
            icon: note.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
            label: note.isPinned ? 'Unpin Note' : 'Pin to Top',
            color: Colors.amber.shade600,
            onTap: () async {
              HapticFeedback.mediumImpact();
              await notesProvider.togglePinNote(note.id);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          _buildOptionTile(
            context: context,
            icon: Icons.share_rounded,
            label: 'Share Note',
            color: Colors.green.shade600,
            onTap: () async {
              HapticFeedback.lightImpact();
              await Share.share(note.toShareText());
              if (context.mounted) Navigator.pop(context);
            },
          ),
          _buildOptionTile(
            context: context,
            icon: Icons.content_copy_rounded,
            label: 'Copy Content',
            color: Colors.purple.shade600,
            onTap: () async {
              HapticFeedback.lightImpact();
              await Clipboard.setData(ClipboardData(text: note.content));
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('Copied to clipboard', style: GoogleFonts.outfit()),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          Divider(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
            height: 1,
          ),
          _buildOptionTile(
            context: context,
            icon: Icons.delete_rounded,
            label: 'Delete Note',
            color: Colors.red.shade500,
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive 
                      ? color 
                      : (isDarkMode ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}

/// Sort options bottom sheet
class SortOptionsSheet extends StatelessWidget {
  final NoteSortOption currentOption;
  final bool isDarkMode;
  final Function(NoteSortOption) onOptionSelected;

  const SortOptionsSheet({
    super.key,
    required this.currentOption,
    required this.isDarkMode,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.sort_rounded,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sort Notes',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          _buildSortOption(
            context: context,
            icon: Icons.update_rounded,
            label: 'Date Modified',
            subtitle: 'Recent changes first',
            option: NoteSortOption.dateModified,
          ),
          _buildSortOption(
            context: context,
            icon: Icons.calendar_today_rounded,
            label: 'Date Created',
            subtitle: 'Newest first',
            option: NoteSortOption.dateCreated,
          ),
          _buildSortOption(
            context: context,
            icon: Icons.sort_by_alpha_rounded,
            label: 'Alphabetical',
            subtitle: 'A to Z',
            option: NoteSortOption.alphabetical,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildSortOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required NoteSortOption option,
  }) {
    final isSelected = currentOption == option;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onOptionSelected(option);
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: isSelected 
              ? (isDarkMode 
                  ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                  : const Color(0xFF3B82F6).withValues(alpha: 0.1))
              : null,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected 
                      ? Colors.white 
                      : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : (isDarkMode ? Colors.white : Colors.black87),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
