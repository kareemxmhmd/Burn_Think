import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/database/app_database.dart';
import '../../domain/models/note.dart';
import '../../domain/repositories/note_repository.dart';

class SqliteNoteRepository implements NoteRepository {
  final AppDatabase _appDatabase;

  SqliteNoteRepository({AppDatabase? appDatabase}) : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  @override
  Future<List<Note>> getAllNotes() async {
    final db = await _db;
    final results = await db.query(
      'notes',
      orderBy: 'isPinned DESC, createdAt DESC',
    );
    return results.map((m) => Note.fromMap(m)).toList();
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final db = await _db;
    final results = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Note.fromMap(results.first);
  }

  @override
  Future<Note?> getQuickNote() async {
    final db = await _db;
    // Pinned note first, otherwise latest updated/created note
    final results = await db.query(
      'notes',
      orderBy: 'isPinned DESC, updatedAt DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Note.fromMap(results.first);
  }

  @override
  Future<void> insertNote(Note note) async {
    final db = await _db;
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateNote(Note note) async {
    final db = await _db;
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> deleteNote(String id) async {
    final db = await _db;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> togglePinNote(String id, bool isPinned) async {
    final db = await _db;
    await db.update(
      'notes',
      {'isPinned': isPinned ? 1 : 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
