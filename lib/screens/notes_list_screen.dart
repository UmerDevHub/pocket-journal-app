import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import '../services/stats_service.dart';
import '../widgets/note_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_options_sheet.dart';
import '../widgets/writing_prompts.dart';
import '../widgets/motivation_card.dart';
import 'note_editor_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

/// Main screen displaying all notes with search
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final StatsService _statsService = StatsService();
  bool _isSearching = false;
  int _currentStreak = 0;
  String _greeting = '';
  String? _userName;
  late AnimationController _fabAnimationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    _loadStats();
  }

  Future<void> _loadStats() async {
    final streak = await _statsService.getCurrentStreak();
    final name = await _statsService.getUserName();
    setState(() {
      _currentStreak = streak;
      _greeting = _statsService.getGreeting();
      _userName = name;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  void _navigateToEditor({String? noteId, String? initialContent, String? color}) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            NoteEditorScreen(noteId: noteId, initialContent: initialContent, initialColor: color),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    ).then((_) => _loadStats());
  }

  void _navigateToSettings() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _navigateToStats() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const StatsScreen()),
    );
  }

  void _showWritingPrompts(bool isDarkMode) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => WritingPromptsSheet(
        isDarkMode: isDarkMode,
        onPromptSelected: (prompt) {
          _navigateToEditor(initialContent: prompt);
        },
      ),
    );
  }

  void _showNoteOptions(BuildContext context, dynamic note, NotesProvider notesProvider, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NoteOptionsSheet(
        note: note,
        notesProvider: notesProvider,
        isDarkMode: isDarkMode,
        onEdit: () => _navigateToEditor(noteId: note.id),
        onDelete: () => _deleteNoteWithUndo(note, notesProvider, isDarkMode),
      ),
    );
  }

  void _showSortOptions(BuildContext context, NotesProvider notesProvider, bool isDarkMode) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortOptionsSheet(
        currentOption: notesProvider.sortOption,
        isDarkMode: isDarkMode,
        onOptionSelected: (option) {
          notesProvider.setSortOption(option);
        },
      ),
    );
  }

  void _deleteNoteWithUndo(dynamic note, NotesProvider notesProvider, bool isDarkMode) {
    notesProvider.deleteNote(note.id);
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Note deleted', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.amber,
          onPressed: () async {
            await notesProvider.undoDelete();
            if (mounted) HapticFeedback.mediumImpact();
          },
        ),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final notesProvider = Provider.of<NotesProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0D0D0D) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Animated Header
            FadeTransition(
              opacity: _headerAnimation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(_headerAnimation),
                child: _buildHeader(isDarkMode, themeProvider, notesProvider),
              ),
            ),
            // Search bar
            _buildSearchBar(isDarkMode, notesProvider),
            // Content
            Expanded(
              child: _buildContent(isDarkMode, notesProvider),
            ),
          ],
        ),
      ),
      // Premium FAB
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _navigateToEditor(),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            highlightElevation: 0,
            icon: const Icon(Icons.add_rounded, size: 24),
            label: Text('New Note', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, ThemeProvider themeProvider, NotesProvider notesProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _userName != null ? '$_greeting, $_userName' : _greeting,
                      style: GoogleFonts.outfit(fontSize: 14, color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600),
                    ),
                    if (_currentStreak > 0) ...[
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _navigateToStats,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFF7931E)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 3),
                              Text('$_currentStreak', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: isDarkMode ? [Colors.white, Colors.white70] : [const Color(0xFF1E293B), const Color(0xFF475569)],
                  ).createShader(bounds),
                  child: Text(
                    'Pocket Journal',
                    style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${notesProvider.totalCount} notes',
                      style: GoogleFonts.outfit(fontSize: 12, color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500),
                    ),
                    if (notesProvider.pinnedCount > 0) ...[
                      Text(' • ', style: TextStyle(color: Colors.grey.shade600)),
                      Icon(Icons.push_pin_rounded, size: 11, color: Colors.amber.shade600),
                      Text(' ${notesProvider.pinnedCount}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.amber.shade600)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _buildIconButton(icon: Icons.bar_chart_rounded, color: const Color(0xFFFF6B35), isDarkMode: isDarkMode, onTap: _navigateToStats),
                  const SizedBox(width: 6),
                  _buildIconButton(
                    icon: Icons.sort_rounded,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    isDarkMode: isDarkMode,
                    onTap: () => _showSortOptions(context, notesProvider, isDarkMode),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildIconButton(
                    icon: isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDarkMode ? Colors.amber : Colors.indigo,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      themeProvider.toggleTheme();
                    },
                  ),
                  const SizedBox(width: 6),
                  _buildIconButton(
                    icon: Icons.settings_rounded,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    isDarkMode: isDarkMode,
                    onTap: _navigateToSettings,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required Color color, required bool isDarkMode, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode, NotesProvider notesProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 46,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withValues(alpha: 0.07) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isSearching ? const Color(0xFF3B82F6) : (isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200),
                  width: _isSearching ? 2 : 1,
                ),
                boxShadow: [if (!isDarkMode) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => notesProvider.setSearchQuery(value),
                onTap: () => setState(() => _isSearching = true),
                onSubmitted: (_) => setState(() => _isSearching = false),
                style: GoogleFonts.outfit(color: isDarkMode ? Colors.white : Colors.black87, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: GoogleFonts.outfit(color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: _isSearching ? const Color(0xFF3B82F6) : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400), size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            notesProvider.clearSearch();
                            setState(() => _isSearching = false);
                          },
                          child: const Icon(Icons.close_rounded, size: 18),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _showWritingPrompts(isDarkMode),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDarkMode, NotesProvider notesProvider) {
    if (notesProvider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 50, height: 50, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)))),
            const SizedBox(height: 16),
            Text('Loading notes...', style: GoogleFonts.outfit(color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600)),
          ],
        ),
      );
    }

    if (notesProvider.isEmpty) {
      return EmptyState(
        isDarkMode: isDarkMode,
        onCreateNote: () => _navigateToEditor(),
        onShowPrompts: () => _showWritingPrompts(isDarkMode),
      );
    }

    final notes = notesProvider.notes;

    if (notes.isEmpty && notesProvider.searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
              child: Icon(Icons.search_off_rounded, size: 48, color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
            ),
            const SizedBox(height: 20),
            Text('No notes found', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await notesProvider.loadNotes();
        await _loadStats();
      },
      color: const Color(0xFF3B82F6),
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // Motivation card
          SliverToBoxAdapter(
            child: MotivationCard(isDarkMode: isDarkMode),
          ),
          // Quick actions
          SliverToBoxAdapter(
            child: QuickActionsRow(
              isDarkMode: isDarkMode,
              onCreateNote: (content, color) => _navigateToEditor(initialContent: content, color: color),
            ),
          ),
          // Section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                'Your Notes',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ),
          ),
          // Notes list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final note = notes[index];
                return NoteCard(
                  note: note,
                  isDarkMode: isDarkMode,
                  index: index,
                  onTap: () => _navigateToEditor(noteId: note.id),
                  onLongPress: () => _showNoteOptions(context, note, notesProvider, isDarkMode),
                  onDelete: () => _deleteNoteWithUndo(note, notesProvider, isDarkMode),
                );
              },
              childCount: notes.length,
            ),
          ),
          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
