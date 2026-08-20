class Exercise {
  final String id;
  final String workoutId;
  final String? category; // e.g. "Chest", "Shoulders", "Legs"
  final String name;
  final int sets;
  final int repetitions;
  final double? weight;
  final int? durationSeconds;
  final String? notes;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Exercise({
    required this.id,
    required this.workoutId,
    this.category,
    required this.name,
    this.sets = 3,
    this.repetitions = 10,
    this.weight,
    this.durationSeconds,
    this.notes,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Exercise copyWith({
    String? id,
    String? workoutId,
    String? category,
    String? name,
    int? sets,
    int? repetitions,
    double? weight,
    int? durationSeconds,
    String? notes,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      category: category ?? this.category,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      repetitions: repetitions ?? this.repetitions,
      weight: weight ?? this.weight,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workoutId': workoutId,
      'category': category,
      'name': name,
      'sets': sets,
      'repetitions': repetitions,
      'weight': weight,
      'durationSeconds': durationSeconds,
      'notes': notes,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      workoutId: map['workoutId'] as String,
      category: map['category'] as String?,
      name: map['name'] as String,
      sets: map['sets'] as int? ?? 3,
      repetitions: map['repetitions'] as int? ?? 10,
      weight: (map['weight'] as num?)?.toDouble(),
      durationSeconds: map['durationSeconds'] as int?,
      notes: map['notes'] as String?,
      sortOrder: map['sortOrder'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise.fromMap(json);
}

class Workout {
  final String id;
  final String name;
  final String? targetTime; // e.g. "18:00"
  final int? estimatedDurationMinutes; // e.g. 45
  final String? notes;
  final bool isCurrentFocus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Exercise> exercises;

  const Workout({
    required this.id,
    required this.name,
    this.targetTime,
    this.estimatedDurationMinutes,
    this.notes,
    this.isCurrentFocus = false,
    required this.createdAt,
    required this.updatedAt,
    this.exercises = const [],
  });

  Workout copyWith({
    String? id,
    String? name,
    String? targetTime,
    int? estimatedDurationMinutes,
    String? notes,
    bool? isCurrentFocus,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Exercise>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      targetTime: targetTime ?? this.targetTime,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      notes: notes ?? this.notes,
      isCurrentFocus: isCurrentFocus ?? this.isCurrentFocus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetTime': targetTime,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'notes': notes,
      'isCurrentFocus': isCurrentFocus ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map, {List<Exercise> exercises = const []}) {
    return Workout(
      id: map['id'] as String,
      name: map['name'] as String,
      targetTime: map['targetTime'] as String?,
      estimatedDurationMinutes: map['estimatedDurationMinutes'] as int?,
      notes: map['notes'] as String?,
      isCurrentFocus: (map['isCurrentFocus'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      exercises: exercises,
    );
  }

  Map<String, dynamic> toJson() {
    final map = toMap();
    map['exercises'] = exercises.map((e) => e.toJson()).toList();
    return map;
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'] as List<dynamic>? ?? [];
    final exercises = rawExercises.map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList();
    return Workout.fromMap(json, exercises: exercises);
  }
}
