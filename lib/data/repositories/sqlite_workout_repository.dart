import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/database/app_database.dart';
import '../../domain/models/workout.dart';
import '../../domain/repositories/workout_repository.dart';

class SqliteWorkoutRepository implements WorkoutRepository {
  final AppDatabase _appDatabase;

  SqliteWorkoutRepository({AppDatabase? appDatabase}) : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  Future<List<Exercise>> _getExercisesForWorkout(DatabaseExecutor db, String workoutId) async {
    final results = await db.query(
      'exercises',
      where: 'workoutId = ?',
      whereArgs: [workoutId],
      orderBy: 'sortOrder ASC, createdAt ASC',
    );
    return results.map((m) => Exercise.fromMap(m)).toList();
  }

  @override
  Future<List<Workout>> getAllWorkouts() async {
    final db = await _db;
    final results = await db.query(
      'workouts',
      orderBy: 'isCurrentFocus DESC, createdAt DESC',
    );

    final workouts = <Workout>[];
    for (final map in results) {
      final id = map['id'] as String;
      final exercises = await _getExercisesForWorkout(db, id);
      workouts.add(Workout.fromMap(map, exercises: exercises));
    }
    return workouts;
  }

  @override
  Future<Workout?> getCurrentFocusWorkout() async {
    final db = await _db;
    final results = await db.query(
      'workouts',
      where: 'isCurrentFocus = 1',
      limit: 1,
    );
    if (results.isEmpty) {
      // Fallback to most recent workout if none is explicitly marked as current focus
      final fallback = await db.query(
        'workouts',
        orderBy: 'createdAt DESC',
        limit: 1,
      );
      if (fallback.isEmpty) return null;
      final id = fallback.first['id'] as String;
      final exercises = await _getExercisesForWorkout(db, id);
      return Workout.fromMap(fallback.first, exercises: exercises);
    }
    final id = results.first['id'] as String;
    final exercises = await _getExercisesForWorkout(db, id);
    return Workout.fromMap(results.first, exercises: exercises);
  }

  @override
  Future<Workout?> getWorkoutById(String id) async {
    final db = await _db;
    final results = await db.query(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    final exercises = await _getExercisesForWorkout(db, id);
    return Workout.fromMap(results.first, exercises: exercises);
  }

  @override
  Future<void> insertWorkout(Workout workout) async {
    final db = await _db;
    await db.transaction((txn) async {
      if (workout.isCurrentFocus) {
        await txn.update('workouts', {'isCurrentFocus': 0});
      }
      await txn.insert(
        'workouts',
        workout.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final exercise in workout.exercises) {
        await txn.insert(
          'exercises',
          exercise.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> updateWorkout(Workout workout) async {
    final db = await _db;
    await db.transaction((txn) async {
      if (workout.isCurrentFocus) {
        await txn.update(
          'workouts',
          {'isCurrentFocus': 0},
          where: 'id != ?',
          whereArgs: [workout.id],
        );
      }
      await txn.update(
        'workouts',
        workout.toMap(),
        where: 'id = ?',
        whereArgs: [workout.id],
      );
    });
  }

  @override
  Future<void> deleteWorkout(String id) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        'exercises',
        where: 'workoutId = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'workouts',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<void> setCurrentFocusWorkout(String id) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update('workouts', {'isCurrentFocus': 0});
      await txn.update(
        'workouts',
        {'isCurrentFocus': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<void> insertExercise(Exercise exercise) async {
    final db = await _db;
    await db.insert(
      'exercises',
      exercise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateExercise(Exercise exercise) async {
    final db = await _db;
    await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  @override
  Future<void> deleteExercise(String exerciseId) async {
    final db = await _db;
    await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [exerciseId],
    );
  }

  @override
  Future<void> reorderExercises(String workoutId, List<String> exerciseIdsInOrder) async {
    final db = await _db;
    await db.transaction((txn) async {
      for (var i = 0; i < exerciseIdsInOrder.length; i++) {
        await txn.update(
          'exercises',
          {'sortOrder': i},
          where: 'id = ? AND workoutId = ?',
          whereArgs: [exerciseIdsInOrder[i], workoutId],
        );
      }
    });
  }
}
