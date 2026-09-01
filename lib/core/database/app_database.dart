import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'migrations.dart';

class AppDatabase {
  static AppDatabase? _instance;
  Database? _database;

  AppDatabase._();

  static AppDatabase get instance => _instance ??= AppDatabase._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static void initializeFfi() {
    if (kIsWeb) return;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> _initDatabase([String? customPath]) async {
    initializeFfi();

    String dbPath;
    if (customPath != null) {
      dbPath = customPath;
    } else {
      final appSupportDir = await getApplicationSupportDirectory();
      await Directory(appSupportDir.path).create(recursive: true);
      dbPath = p.join(appSupportDir.path, 'burn_think.db');
    }

    return await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: DatabaseMigrations.currentVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: DatabaseMigrations.onCreate,
        onUpgrade: DatabaseMigrations.onUpgrade,
      ),
    );
  }

  /// Create an in-memory database for testing
  static Future<AppDatabase> createInMemory() async {
    initializeFfi();
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseMigrations.currentVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: DatabaseMigrations.onCreate,
        onUpgrade: DatabaseMigrations.onUpgrade,
      ),
    );

    final instance = AppDatabase._();
    instance._database = db;
    return instance;
  }

  /// Reset the entire database (destructive)
  Future<void> resetDatabase() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('exercises');
      await txn.delete('workouts');
      await txn.delete('project_items');
      await txn.delete('projects');
      await txn.delete('tasks');
      await txn.delete('content_items');
      await txn.delete('notes');
      await txn.delete('shopping_items');
      await txn.delete('ml_events');
    });
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
