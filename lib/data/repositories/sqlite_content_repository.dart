import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/database/app_database.dart';
import '../../domain/models/content_item.dart';
import '../../domain/repositories/content_repository.dart';

class SqliteContentRepository implements ContentRepository {
  final AppDatabase _appDatabase;

  SqliteContentRepository({AppDatabase? appDatabase}) : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  @override
  Future<List<ContentItem>> getAllContentItems() async {
    final db = await _db;
    final results = await db.query(
      'content_items',
      orderBy: 'createdAt DESC',
    );
    return results.map((m) => ContentItem.fromMap(m)).toList();
  }

  @override
  Future<ContentItem?> getContentItemById(String id) async {
    final db = await _db;
    final results = await db.query(
      'content_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return ContentItem.fromMap(results.first);
  }

  @override
  Future<void> insertContentItem(ContentItem item) async {
    final db = await _db;
    await db.insert(
      'content_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateContentItem(ContentItem item) async {
    final db = await _db;
    await db.update(
      'content_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> deleteContentItem(String id) async {
    final db = await _db;
    await db.delete(
      'content_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
