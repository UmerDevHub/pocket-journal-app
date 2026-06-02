import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

/// Database service for local SQLite storage
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  /// Get database instance, creating if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, 'pocket_journal.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        color TEXT NOT NULL,
        isPinned INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add isPinned column
      await db.execute('ALTER TABLE notes ADD COLUMN isPinned INTEGER DEFAULT 0');
    }
  }

  /// Insert a new note
  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing note
  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Delete a note by ID
  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Toggle pin status
  Future<void> togglePinNote(String id) async {
    final db = await database;
    final note = await getNoteById(id);
    if (note != null) {
      await db.update(
        'notes',
        {'isPinned': note.isPinned ? 0 : 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  /// Get all notes ordered by pinned first, then by updated date
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Get all notes sorted alphabetically
  Future<List<Note>> getNotesSortedAlphabetically() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'isPinned DESC, title ASC',
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Get all notes sorted by creation date
  Future<List<Note>> getNotesSortedByCreated() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'isPinned DESC, createdAt DESC',
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Search notes by title or content
  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Get a single note by ID
  Future<Note?> getNoteById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  /// Get notes count
  Future<int> getNotesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM notes');
    return result.first['count'] as int;
  }

  /// Export all notes as a formatted string
  Future<String> exportNotesAsText() async {
    final notes = await getAllNotes();
    final buffer = StringBuffer();
    
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('       POCKET JOURNAL EXPORT');
    buffer.writeln('       ${DateTime.now().toString().split('.').first}');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln();

    for (final note in notes) {
      buffer.writeln('───────────────────────────────────────');
      if (note.isPinned) buffer.writeln('📌 PINNED');
      buffer.writeln('📝 ${note.title}');
      buffer.writeln('   Created: ${note.createdAt.toString().split('.').first}');
      buffer.writeln('   Updated: ${note.updatedAt.toString().split('.').first}');
      buffer.writeln('───────────────────────────────────────');
      buffer.writeln(note.content);
      buffer.writeln();
    }

    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('       Total Notes: ${notes.length}');
    buffer.writeln('═══════════════════════════════════════');

    return buffer.toString();
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
