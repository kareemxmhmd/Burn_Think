import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/app_database.dart';
import '../../domain/models/task.dart';
import '../../domain/models/project.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/content_item.dart';
import '../../domain/models/note.dart';
import '../../domain/models/shopping_item.dart';

class ImportResult {
  final bool success;
  final String message;
  final int tasksImported;
  final int projectsImported;
  final int workoutsImported;
  final int contentItemsImported;
  final int notesImported;
  final int shoppingItemsImported;

  const ImportResult({
    required this.success,
    required this.message,
    this.tasksImported = 0,
    this.projectsImported = 0,
    this.workoutsImported = 0,
    this.contentItemsImported = 0,
    this.notesImported = 0,
    this.shoppingItemsImported = 0,
  });

  int get totalImported =>
      tasksImported +
      projectsImported +
      workoutsImported +
      contentItemsImported +
      notesImported +
      shoppingItemsImported;
}

class ExportImportService {
  final AppDatabase _appDatabase;

  ExportImportService({AppDatabase? appDatabase}) : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  /// Export entire workspace to a JSON string
  Future<String> exportToJsonString() async {
    final db = await _db;

    final tasksRaw = await db.query('tasks');
    final projectsRaw = await db.query('projects');
    final projectItemsRaw = await db.query('project_items');
    final workoutsRaw = await db.query('workouts');
    final exercisesRaw = await db.query('exercises');
    final contentItemsRaw = await db.query('content_items');
    final notesRaw = await db.query('notes');
    final shoppingItemsRaw = await db.query('shopping_items');

    // Assemble nested projects
    final projects = <Map<String, dynamic>>[];
    for (final p in projectsRaw) {
      final pId = p['id'] as String;
      final items = projectItemsRaw.where((i) => i['projectId'] == pId).toList();
      final pMap = Map<String, dynamic>.from(p);
      pMap['items'] = items;
      projects.add(pMap);
    }

    // Assemble nested workouts
    final workouts = <Map<String, dynamic>>[];
    for (final w in workoutsRaw) {
      final wId = w['id'] as String;
      final exercises = exercisesRaw.where((e) => e['workoutId'] == wId).toList();
      final wMap = Map<String, dynamic>.from(w);
      wMap['exercises'] = exercises;
      workouts.add(wMap);
    }

    final payload = {
      'app': 'Burn Think',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'data': {
        'tasks': tasksRaw,
        'projects': projects,
        'workouts': workouts,
        'contentItems': contentItemsRaw,
        'notes': notesRaw,
        'shoppingItems': shoppingItemsRaw,
      },
    };

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(payload);
  }

  /// Validate JSON structure before importing
  bool validateJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return false;
      if (decoded['app'] != 'Burn Think' && decoded['app'] != 'Burn Shut') return false;
      if (decoded['version'] == null) return false;
      if (decoded['data'] is! Map<String, dynamic>) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Import workspace from a JSON string
  Future<ImportResult> importFromJsonString(
    String jsonString, {
    bool replace = false,
  }) async {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return const ImportResult(
          success: false,
          message: 'Invalid backup file format.',
        );
      }

      if (decoded['app'] != 'Burn Think' && decoded['app'] != 'Burn Shut') {
        return const ImportResult(
          success: false,
          message: 'File is not a valid Burn Think backup.',
        );
      }

      final data = decoded['data'] as Map<String, dynamic>?;
      if (data == null) {
        return const ImportResult(
          success: false,
          message: 'Backup data is empty or missing.',
        );
      }

      final db = await _db;
      int tasksCount = 0;
      int projectsCount = 0;
      int workoutsCount = 0;
      int contentCount = 0;
      int notesCount = 0;
      int shoppingCount = 0;

      await db.transaction((txn) async {
        if (replace) {
          await txn.delete('exercises');
          await txn.delete('workouts');
          await txn.delete('project_items');
          await txn.delete('projects');
          await txn.delete('tasks');
          await txn.delete('content_items');
          await txn.delete('notes');
          await txn.delete('shopping_items');
        }

        // 1. Projects & Items
        final projectsRaw = data['projects'] as List<dynamic>? ?? [];
        for (final pJson in projectsRaw) {
          if (pJson is Map<String, dynamic>) {
            final project = Project.fromJson(pJson);
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
            projectsCount++;
          }
        }

        // 2. Tasks
        final tasksRaw = data['tasks'] as List<dynamic>? ?? [];
        for (final tJson in tasksRaw) {
          if (tJson is Map<String, dynamic>) {
            final task = Task.fromJson(tJson);
            await txn.insert(
              'tasks',
              task.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            tasksCount++;
          }
        }

        // 3. Workouts & Exercises
        final workoutsRaw = data['workouts'] as List<dynamic>? ?? [];
        for (final wJson in workoutsRaw) {
          if (wJson is Map<String, dynamic>) {
            final workout = Workout.fromJson(wJson);
            await txn.insert(
              'workouts',
              workout.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            for (final ex in workout.exercises) {
              await txn.insert(
                'exercises',
                ex.toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            workoutsCount++;
          }
        }

        // 4. Content Items
        final contentRaw = data['contentItems'] as List<dynamic>? ?? [];
        for (final cJson in contentRaw) {
          if (cJson is Map<String, dynamic>) {
            final item = ContentItem.fromJson(cJson);
            await txn.insert(
              'content_items',
              item.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            contentCount++;
          }
        }

        // 5. Notes
        final notesRaw = data['notes'] as List<dynamic>? ?? [];
        for (final nJson in notesRaw) {
          if (nJson is Map<String, dynamic>) {
            final note = Note.fromJson(nJson);
            await txn.insert(
              'notes',
              note.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            notesCount++;
          }
        }

        // 6. Shopping Items
        final shoppingRaw = data['shoppingItems'] as List<dynamic>? ?? [];
        for (final sJson in shoppingRaw) {
          if (sJson is Map<String, dynamic>) {
            final item = ShoppingItem.fromJson(sJson);
            await txn.insert(
              'shopping_items',
              item.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            shoppingCount++;
          }
        }
      });

      return ImportResult(
        success: true,
        message: 'Successfully imported data ($tasksCount tasks, $projectsCount projects, $shoppingCount shopping items).',
        tasksImported: tasksCount,
        projectsImported: projectsCount,
        workoutsImported: workoutsCount,
        contentItemsImported: contentCount,
        notesImported: notesCount,
        shoppingItemsImported: shoppingCount,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Import failed: $e',
      );
    }
  }
}
