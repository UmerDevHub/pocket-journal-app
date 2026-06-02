import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Daily motivation card with tips and quotes
class MotivationCard extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback? onTap;

  const MotivationCard({
    super.key,
    required this.isDarkMode,
    this.onTap,
  });

  static const List<Map<String, String>> _motivations = [
    {
      'emoji': '✨',
      'title': 'Tip of the Day',
      'message': 'Write for just 5 minutes. Small steps lead to big changes.',
    },
    {
      'emoji': '🌟',
      'title': 'Daily Reminder',
      'message': 'Your thoughts matter. Capture them before they fade away.',
    },
    {
      'emoji': '💪',
      'title': 'Stay Consistent',
      'message': 'Journaling daily improves mental clarity and reduces stress.',
    },
    {
      'emoji': '🎯',
      'title': 'Focus Tip',
      'message': 'Start with gratitude. Write 3 things you\'re thankful for.',
    },
    {
      'emoji': '🌈',
      'title': 'Creative Boost',
      'message': 'No rules in journaling. Write freely without judgment.',
    },
    {
      'emoji': '🔥',
      'title': 'Keep Going!',
      'message': 'Every note you write is a step towards self-discovery.',
    },
    {
      'emoji': '💡',
      'title': 'Pro Tip',
      'message': 'Review past notes weekly to see your growth and patterns.',
    },
    {
      'emoji': '🌙',
      'title': 'Evening Ritual',
      'message': 'End your day by writing what went well. Sleep better tonight.',
    },
    {
      'emoji': '☀️',
      'title': 'Morning Power',
      'message': 'Start your day with intention. Write your top 3 priorities.',
    },
    {
      'emoji': '🧘',
      'title': 'Mindfulness',
      'message': 'Writing is meditation. Be present with your thoughts.',
    },
  ];

  Map<String, String> get _todaysMotivation {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _motivations[dayOfYear % _motivations.length];
  }

  @override
  Widget build(BuildContext context) {
    final motivation = _todaysMotivation;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF1E3A5F), const Color(0xFF0F2942)]
                : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode
                ? Colors.blue.withValues(alpha: 0.3)
                : Colors.blue.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Emoji container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  motivation['emoji']!,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    motivation['title']!,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    motivation['message']!,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white.withValues(alpha: 0.85) : Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick action buttons for creating notes
class QuickActionsRow extends StatelessWidget {
  final bool isDarkMode;
  final Function(String? content, String? color) onCreateNote;

  const QuickActionsRow({
    super.key,
    required this.isDarkMode,
    required this.onCreateNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 8),
      child: Row(
        children: [
          _buildQuickAction(
            emoji: '📝',
            label: 'New Note',
            color: const Color(0xFF3B82F6),
            onTap: () {
              HapticFeedback.lightImpact();
              onCreateNote(null, null);
            },
          ),
          const SizedBox(width: 12),
          _buildQuickAction(
            emoji: '✅',
            label: 'Todo List',
            color: const Color(0xFF10B981),
            onTap: () {
              HapticFeedback.lightImpact();
              onCreateNote('📋 Todo List\n\n☐ \n☐ \n☐ \n', '#DCFCE7');
            },
          ),
          const SizedBox(width: 12),
          _buildQuickAction(
            emoji: '💡',
            label: 'Quick Idea',
            color: const Color(0xFFF59E0B),
            onTap: () {
              HapticFeedback.lightImpact();
              onCreateNote('💡 Idea\n\n', '#FEF3C7');
            },
          ),
          const SizedBox(width: 12),
          _buildQuickAction(
            emoji: '🙏',
            label: 'Gratitude',
            color: const Color(0xFFEC4899),
            onTap: () {
              HapticFeedback.lightImpact();
              onCreateNote('🙏 Grateful For\n\n1. \n2. \n3. \n', '#FCE7F3');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required String emoji,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? color.withValues(alpha: 0.15)
                : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: isDarkMode ? 0.3 : 0.25),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
