import '../models/workout.dart';

abstract class WorkoutRepository {
  Future<List<Workout>> getAllWorkouts();
  Future<Workout?> getCurrentFocusWorkout();
  Future<Workout?> getWorkoutById(String id);
  Future<void> insertWorkout(Workout workout);
  Future<void> updateWorkout(Workout workout);
  Future<void> deleteWorkout(String id);
  Future<void> setCurrentFocusWorkout(String id);

  // Exercises
  Future<void> insertExercise(Exercise exercise);
  Future<void> updateExercise(Exercise exercise);
  Future<void> deleteExercise(String exerciseId);
  Future<void> reorderExercises(String workoutId, List<String> exerciseIdsInOrder);
}
