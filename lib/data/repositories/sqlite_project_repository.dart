import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/database/app_database.dart';
import '../../domain/models/project.dart';
import '../../domain/repositories/project_repository.dart';

class SqliteProjectRepository implements ProjectRepository {
  final AppDatabase _appDatabase;

  SqliteProjectRepository({AppDatabase? appDatabase}) : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  Future<List<ProjectItem>> _getItemsForProject(DatabaseExecutor db, String projectId) async {
    final results = await db.query(
      'project_items',
      where: 'projectId = ?',
      whereArgs: [projectId],
      orderBy: 'sortOrder ASC, createdAt ASC',
    );
    return results.map((m) => ProjectItem.fromMap(m)).toList();
  }

  @override
  Future<List<Project>> getActiveProjects() async {
    final db = await _db;
    final results = await db.query(
      'projects',
      where: 'isCompleted = 0',
      orderBy: 'createdAt DESC',
    );

    final projects = <Project>[];
    for (final map in results) {
      final id = map['id'] as String;
      final items = await _getItemsForProject(db, id);
      projects.add(Project.fromMap(map, items: items));
    }
    return projects;
  }

  @override
  Future<List<Project>> getCompletedProjects() async {
    final db = await _db;
    final results = await db.query(
      'projects',
      where: 'isCompleted = 1',
      orderBy: 'completedAt DESC, updatedAt DESC',
    );

    final projects = <Project>[];
    for (final map in results) {
      final id = map['id'] as String;
      final items = await _getItemsForProject(db, id);
      projects.add(Project.fromMap(map, items: items));
    }
    return projects;
  }

  @override
  Future<List<Project>> getAllProjects() async {
    final db = await _db;
    final results = await db.query('projects', orderBy: 'createdAt DESC');

    final projects = <Project>[];
    for (final map in results) {
      final id = map['id'] as String;
      final items = await _getItemsForProject(db, id);
      projects.add(Project.fromMap(map, items: items));
    }
    return projects;
  }

  @override
  Future<Project?> getProjectById(String id) async {
    final db = await _db;
    final results = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    final items = await _getItemsForProject(db, id);
    return Project.fromMap(results.first, items: items);
  }

  @override
  Future<void> insertProject(Project project) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert(
        'projects',
        project.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final item in project.items) {
        await txn.insert(
          'project_items',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> updateProject(Project project) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update(
        'projects',
        project.toMap(),
        where: 'id = ?',
        whereArgs: [project.id],
      );
      for (final item in project.items) {
        await txn.insert(
          'project_items',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> deleteProject(String id) async {
    final db = await _db;
    await db.transaction((txn) async {
      // Clear associated project IDs on tasks to avoid orphan constraint or invalid links
      await txn.update(
        'tasks',
        {'projectId': null},
        where: 'projectId = ?',
        whereArgs: [id],
      );
      // Delete project items
      await txn.delete(
        'project_items',
        where: 'projectId = ?',
        whereArgs: [id],
      );
      // Delete project
      await txn.delete(
        'projects',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<void> setProjectCompleted(String id, bool isCompleted, {DateTime? completedAt}) async {
    final db = await _db;
    final now = DateTime.now();
    await db.update(
      'projects',
      {
        'isCompleted': isCompleted ? 1 : 0,
        'completedAt': isCompleted ? (completedAt ?? now).toIso8601String() : null,
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> insertProjectItem(ProjectItem item) async {
    final db = await _db;
    await db.insert(
      'project_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateProjectItem(ProjectItem item) async {
    final db = await _db;
    await db.update(
      'project_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> deleteProjectItem(String itemId) async {
    final db = await _db;
    await db.delete(
      'project_items',
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  @override
  Future<void> setProjectItemCompleted(String itemId, bool isCompleted, {DateTime? completedAt}) async {
    final db = await _db;
    final now = DateTime.now();
    await db.update(
      'project_items',
      {
        'isCompleted': isCompleted ? 1 : 0,
        'completedAt': isCompleted ? (completedAt ?? now).toIso8601String() : null,
        'updatedAt': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }
}
