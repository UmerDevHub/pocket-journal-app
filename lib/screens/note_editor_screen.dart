import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import '../services/stats_service.dart';
import '../widgets/color_picker.dart';

/// Premium note editor screen for creating and editing notes
class NoteEditorScreen extends StatefulWidget {
  final String? noteId;
  final String? initialContent;
  final String? initialColor;

  const NoteEditorScreen({super.key, this.noteId, this.initialContent, this.initialColor});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final StatsService _statsService = StatsService();
  
  late Note _currentNote;
  bool _isNewNote = true;
  bool _hasChanges = false;
  bool _isSaving = false;
  int _initialWordCount = 0;
  Timer? _autoSaveTimer;
  late AnimationController _saveAnimationController;
  late Animation<double> _saveAnimation;

  @override
  void initState() {
    super.initState();
    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _saveAnimation = CurvedAnimation(
      parent: _saveAnimationController,
      curve: Curves.easeInOut,
    );
    _initializeNote();
  }

  void _initializeNote() {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    
    if (widget.noteId != null) {
      final existingNote = notesProvider.getNoteById(widget.noteId!);
      if (existingNote != null) {
        _currentNote = existingNote;
        _contentController.text = existingNote.content;
        _isNewNote = false;
        _initialWordCount = _countWords(existingNote.content);
      } else {
        _createNewNote(notesProvider);
      }
    } else {
      _createNewNote(notesProvider);
      // Apply initial content from prompt if provided
      if (widget.initialContent != null) {
        _contentController.text = widget.initialContent!;
        _hasChanges = true;
      }
      // Apply initial color from quick action if provided
      if (widget.initialColor != null) {
        _currentNote = _currentNote.copyWith(color: widget.initialColor);
      }
    }
    
    _contentController.addListener(_onContentChanged);
    
    // Auto focus for new notes
    if (_isNewNote) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _createNewNote(NotesProvider notesProvider) {
    _currentNote = notesProvider.createNewNote();
    _isNewNote = true;
  }

  void _onContentChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
      _saveAnimationController.forward();
    }
    
    // Debounced auto-save
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      _saveNote(showSnackbar: false);
    });
  }

  int _countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  Future<void> _saveNote({bool showSnackbar = true}) async {
    if (!_hasChanges && !_isNewNote) return;
    
    final content = _contentController.text;
    if (content.trim().isEmpty && _isNewNote) return;
    
    setState(() => _isSaving = true);
    
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    
    final updatedNote = _currentNote.copyWith(
      content: content,
      title: Note.generateTitle(content),
      updatedAt: DateTime.now(),
    );
    
    if (_isNewNote) {
      await notesProvider.addNote(updatedNote);
      await _statsService.incrementNotesCreated();
      await _statsService.updateStreak();
      _isNewNote = false;
    } else {
      await notesProvider.updateNote(updatedNote);
    }
    
    // Track words added
    final currentWordCount = _countWords(content);
    final wordsAdded = currentWordCount - _initialWordCount;
    if (wordsAdded > 0) {
      await _statsService.addWords(wordsAdded);
      _initialWordCount = currentWordCount;
    }
    
    _currentNote = updatedNote;
    _hasChanges = false;
    _saveAnimationController.reverse();
    
    setState(() => _isSaving = false);
    
    if (showSnackbar && mounted) {
      HapticFeedback.lightImpact();
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
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                'Saved!',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 1),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _changeColor(String color) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentNote = _currentNote.copyWith(color: color);
      _hasChanges = true;
    });
    _saveAnimationController.forward();
  }

  Future<bool> _onWillPop() async {
    _autoSaveTimer?.cancel();
    await _saveNote(showSnackbar: false);
    return true;
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _contentController.dispose();
    _focusNode.dispose();
    _saveAnimationController.dispose();
    super.dispose();
  }

  int get _wordCount => _countWords(_contentController.text);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final noteColor = _hexToColor(_currentNote.color);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _onWillPop()) {
          if (mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode 
            ? Color.lerp(const Color(0xFF0D0D0D), noteColor, 0.08)
            : Color.lerp(Colors.white, noteColor, 0.15),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  // Back button
                  _buildAppBarButton(
                    icon: Icons.arrow_back_rounded,
                    isDarkMode: isDarkMode,
                    onTap: () async {
                      if (await _onWillPop()) {
                        if (mounted) Navigator.of(context).pop();
                      }
                    },
                  ),
                  const Spacer(),
                  // Saving indicator
                  AnimatedBuilder(
                    animation: _saveAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _saveAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isSaving) ...[
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDarkMode ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                _isSaving ? 'Saving...' : 'Unsaved',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.white60 : Colors.black45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Color picker
                  ColorPickerPopup(
                    selectedColor: _currentNote.color,
                    isDarkMode: isDarkMode,
                    onColorSelected: _changeColor,
                  ),
                  const SizedBox(width: 4),
                  // Save button
                  _buildSaveButton(isDarkMode),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Editor card
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? const Color(0xFF1A1A1A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: TextField(
                    controller: _contentController,
                    focusNode: _focusNode,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      height: 1.7,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      letterSpacing: 0.1,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start writing...',
                      hintStyle: GoogleFonts.outfit(
                        fontSize: 17,
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(24),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom bar with word count
            Container(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Word count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          size: 14,
                          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$_wordCount ${_wordCount == 1 ? 'word' : 'words'}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Char count
                  Text(
                    '${_contentController.text.length} chars',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500,
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

  Widget _buildAppBarButton({
    required IconData icon,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDarkMode 
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: isDarkMode ? Colors.white : Colors.black87,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isDarkMode) {
    return GestureDetector(
      onTap: () => _saveNote(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: _hasChanges
              ? const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                )
              : null,
          color: _hasChanges 
              ? null
              : (isDarkMode 
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _hasChanges ? [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Icon(
          Icons.check_rounded,
          color: _hasChanges 
              ? Colors.white
              : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
          size: 22,
        ),
      ),
    );
  }
}
