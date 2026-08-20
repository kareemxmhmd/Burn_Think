import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/database/app_database.dart';
import '../../domain/models/task.dart';
import '../../domain/repositories/task_repository.dart';

class SqliteTaskRepository implements TaskRepository {
  final AppDatabase _appDatabase;

  SqliteTaskRepository({AppDatabase? appDatabase}) : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  @override
  Future<List<Task>> getActiveTasks() async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT t.*, p.title as projectName
      FROM tasks t
      LEFT JOIN projects p ON t.projectId = p.id
      WHERE t.isCompleted = 0
      ORDER BY t.priority DESC, t.dueDate ASC, t.createdAt DESC
    ''');
    return results.map((m) => Task.fromMap(m)).toList();
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT t.*, p.title as projectName
      FROM tasks t
      LEFT JOIN projects p ON t.projectId = p.id
      WHERE t.isCompleted = 1
      ORDER BY t.completedAt DESC, t.updatedAt DESC
    ''');
    return results.map((m) => Task.fromMap(m)).toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT t.*, p.title as projectName
      FROM tasks t
      LEFT JOIN projects p ON t.projectId = p.id
      WHERE t.id = ?
      LIMIT 1
    ''', [id]);
    if (results.isEmpty) return null;
    return Task.fromMap(results.first);
  }

  @override
  Future<void> insertTask(Task task) async {
    final db = await _db;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateTask(Task task) async {
    final db = await _db;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    final db = await _db;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> setTaskCompleted(String id, bool isCompleted, {DateTime? completedAt}) async {
    final db = await _db;
    final now = DateTime.now();
    await db.update(
      'tasks',
      {
        'isCompleted': isCompleted ? 1 : 0,
        'completedAt': isCompleted ? (completedAt ?? now).toIso8601String() : null,
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
