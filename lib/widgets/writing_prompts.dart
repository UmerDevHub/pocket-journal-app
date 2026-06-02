import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Writing prompts and inspiration widget
class WritingPromptsSheet extends StatelessWidget {
  final bool isDarkMode;
  final Function(String) onPromptSelected;

  const WritingPromptsSheet({
    super.key,
    required this.isDarkMode,
    required this.onPromptSelected,
  });

  static const List<Map<String, dynamic>> _prompts = [
    {
      'emoji': '🌅',
      'title': 'Morning Reflection',
      'prompt': 'What are 3 things I\'m grateful for today?\n\n1. \n2. \n3. \n\nWhat would make today great?\n',
    },
    {
      'emoji': '🌙',
      'title': 'Evening Review',
      'prompt': 'What went well today?\n\nWhat could I have done better?\n\nWhat did I learn?\n',
    },
    {
      'emoji': '💭',
      'title': 'Free Writing',
      'prompt': 'Take 5 minutes to write whatever comes to mind...\n\n',
    },
    {
      'emoji': '🎯',
      'title': 'Goals & Dreams',
      'prompt': 'My biggest goal right now is:\n\nFirst step I can take:\n\nWhat\'s holding me back?\n',
    },
    {
      'emoji': '❤️',
      'title': 'Self-Care Check',
      'prompt': 'How am I feeling right now?\n\nWhat do I need today?\n\nOne thing I love about myself:\n',
    },
    {
      'emoji': '💡',
      'title': 'Ideas Dump',
      'prompt': 'Random ideas, thoughts, and things I want to remember:\n\n• \n• \n• \n',
    },
    {
      'emoji': '📚',
      'title': 'Book/Movie Notes',
      'prompt': 'Title:\n\nKey takeaways:\n\nFavorite quote:\n\nMy thoughts:\n',
    },
    {
      'emoji': '✈️',
      'title': 'Travel Memory',
      'prompt': 'Where did I go?\n\nBest moment:\n\nWhat I discovered:\n\nWould I go back?\n',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
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
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Writing Prompts',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'Get inspired to start writing',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
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
          // Prompts list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _prompts.length,
              itemBuilder: (context, index) {
                final prompt = _prompts[index];
                return _buildPromptTile(context, prompt, index);
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildPromptTile(BuildContext context, Map<String, dynamic> prompt, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isDarkMode 
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode 
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.shade200,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              onPromptSelected(prompt['prompt'] as String);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    prompt['emoji'] as String,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      prompt['title'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
