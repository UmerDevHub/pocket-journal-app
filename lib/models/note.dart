import 'dart:convert';

/// Note model representing a single journal entry
class Note {
  final String id;
  final String title;
  final String content;
  final String color;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a Note from a Map (database row)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      color: map['color'] as String,
      isPinned: (map['isPinned'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Convert Note to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'isPinned': isPinned ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of Note with some fields updated
  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? color,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Generate title from content (first line or first 50 chars)
  static String generateTitle(String content) {
    if (content.isEmpty) return 'Untitled Note';
    
    final firstLine = content.split('\n').first.trim();
    if (firstLine.isEmpty) return 'Untitled Note';
    
    return firstLine.length > 50 
        ? '${firstLine.substring(0, 50)}...' 
        : firstLine;
  }

  /// Get a snippet of the content for preview (excluding title line)
  String get snippet {
    final lines = content.split('\n');
    if (lines.length <= 1) return '';
    
    final snippetText = lines.skip(1).join('\n').trim();
    return snippetText.length > 100 
        ? '${snippetText.substring(0, 100)}...' 
        : snippetText;
  }

  /// Get shareable text format
  String toShareText() {
    return '$title\n\n$content\n\n---\nCreated with Pocket Journal';
  }

  /// Convert to JSON string
  String toJson() => json.encode(toMap());

  /// Create Note from JSON string
  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Note(id: $id, title: $title, isPinned: $isPinned, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
