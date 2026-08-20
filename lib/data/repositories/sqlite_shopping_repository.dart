import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/database/app_database.dart';
import '../../domain/models/shopping_item.dart';
import '../../domain/repositories/shopping_repository.dart';

class SqliteShoppingRepository implements ShoppingRepository {
  final AppDatabase _appDatabase;

  SqliteShoppingRepository({AppDatabase? appDatabase}) : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  @override
  Future<List<ShoppingItem>> getToBuyItems() async {
    final db = await _db;
    final results = await db.query(
      'shopping_items',
      where: 'isBought = 0',
      orderBy: 'createdAt DESC',
    );
    return results.map((m) => ShoppingItem.fromMap(m)).toList();
  }

  @override
  Future<List<ShoppingItem>> getBoughtItems() async {
    final db = await _db;
    final results = await db.query(
      'shopping_items',
      where: 'isBought = 1',
      orderBy: 'boughtAt DESC, updatedAt DESC',
    );
    return results.map((m) => ShoppingItem.fromMap(m)).toList();
  }

  @override
  Future<ShoppingItem?> getShoppingItemById(String id) async {
    final db = await _db;
    final results = await db.query(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return ShoppingItem.fromMap(results.first);
  }

  @override
  Future<void> insertShoppingItem(ShoppingItem item) async {
    final db = await _db;
    await db.insert(
      'shopping_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateShoppingItem(ShoppingItem item) async {
    final db = await _db;
    await db.update(
      'shopping_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> deleteShoppingItem(String id) async {
    final db = await _db;
    await db.delete(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> setShoppingItemBought(String id, bool isBought, {DateTime? boughtAt}) async {
    final db = await _db;
    final now = DateTime.now();
    await db.update(
      'shopping_items',
      {
        'isBought': isBought ? 1 : 0,
        'boughtAt': isBought ? (boughtAt ?? now).toIso8601String() : null,
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
