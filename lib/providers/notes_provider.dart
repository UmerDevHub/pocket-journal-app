import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/database_service.dart';

/// Sort options for notes
enum NoteSortOption {
  dateModified,
  dateCreated,
  alphabetical,
}

/// Provider for managing notes state
class NotesProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();
  
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String _searchQuery = '';
  bool _isLoading = true;
  NoteSortOption _sortOption = NoteSortOption.dateModified;
  
  // For undo delete feature
  Note? _lastDeletedNote;

  /// Get all notes (filtered if search is active)
  List<Note> get notes => _searchQuery.isEmpty ? _notes : _filteredNotes;

  /// Check if currently loading
  bool get isLoading => _isLoading;

  /// Get current search query
  String get searchQuery => _searchQuery;

  /// Check if notes list is empty
  bool get isEmpty => _notes.isEmpty;

  /// Get current sort option
  NoteSortOption get sortOption => _sortOption;

  /// Get last deleted note for undo
  Note? get lastDeletedNote => _lastDeletedNote;

  /// Get pinned notes count
  int get pinnedCount => _notes.where((n) => n.isPinned).length;

  /// Get total notes count
  int get totalCount => _notes.length;

  /// Initialize provider and load notes
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    await loadNotes();
    
    _isLoading = false;
    notifyListeners();
  }

  /// Load all notes from database
  Future<void> loadNotes() async {
    switch (_sortOption) {
      case NoteSortOption.dateModified:
        _notes = await _databaseService.getAllNotes();
        break;
      case NoteSortOption.dateCreated:
        _notes = await _databaseService.getNotesSortedByCreated();
        break;
      case NoteSortOption.alphabetical:
        _notes = await _databaseService.getNotesSortedAlphabetically();
        break;
    }
    if (_searchQuery.isNotEmpty) {
      _applySearch();
    }
    notifyListeners();
  }

  /// Set sort option
  Future<void> setSortOption(NoteSortOption option) async {
    _sortOption = option;
    await loadNotes();
  }

  /// Create a new note with default values
  Note createNewNote({String color = '#FEF3C7'}) {
    final now = DateTime.now();
    return Note(
      id: _uuid.v4(),
      title: 'Untitled Note',
      content: '',
      color: color,
      isPinned: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Add a new note
  Future<void> addNote(Note note) async {
    await _databaseService.insertNote(note);
    await loadNotes();
  }

  /// Update an existing note
  Future<void> updateNote(Note note) async {
    final updatedNote = note.copyWith(
      title: Note.generateTitle(note.content),
      updatedAt: DateTime.now(),
    );
    await _databaseService.updateNote(updatedNote);
    await loadNotes();
  }

  /// Delete a note (with undo support)
  Future<void> deleteNote(String id) async {
    // Store for undo
    _lastDeletedNote = _notes.firstWhere((n) => n.id == id, orElse: () => _notes.first);
    
    await _databaseService.deleteNote(id);
    await loadNotes();
  }

  /// Undo last delete
  Future<bool> undoDelete() async {
    if (_lastDeletedNote == null) return false;
    
    await _databaseService.insertNote(_lastDeletedNote!);
    _lastDeletedNote = null;
    await loadNotes();
    return true;
  }

  /// Clear last deleted note (call after undo timeout)
  void clearLastDeleted() {
    _lastDeletedNote = null;
  }

  /// Toggle pin status
  Future<void> togglePinNote(String id) async {
    await _databaseService.togglePinNote(id);
    await loadNotes();
  }

  /// Set search query and filter notes
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    _applySearch();
    notifyListeners();
  }

  /// Apply search filter to notes
  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredNotes = [];
      return;
    }
    
    final lowerQuery = _searchQuery.toLowerCase();
    _filteredNotes = _notes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
             note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredNotes = [];
    notifyListeners();
  }

  /// Export all notes as text
  Future<String> exportNotes() async {
    return await _databaseService.exportNotesAsText();
  }

  /// Get a note by ID
  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
}
