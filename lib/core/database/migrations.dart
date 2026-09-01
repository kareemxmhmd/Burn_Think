import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract final class DatabaseMigrations {
  static const int currentVersion = 2;

  static Future<void> onCreate(Database db, int version) async {
    final batch = db.batch();

    // 1. Tasks
    batch.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        priority INTEGER NOT NULL DEFAULT 0,
        dueDate TEXT,
        projectId TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    batch.execute('CREATE INDEX idx_tasks_completed ON tasks(isCompleted)');
    batch.execute('CREATE INDEX idx_tasks_project ON tasks(projectId)');
    batch.execute('CREATE INDEX idx_tasks_created ON tasks(createdAt)');

    // 2. Projects
    batch.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    batch.execute('CREATE INDEX idx_projects_completed ON projects(isCompleted)');
    batch.execute('CREATE INDEX idx_projects_created ON projects(createdAt)');

    // 3. Project Items
    batch.execute('''
      CREATE TABLE project_items (
        id TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        sortOrder INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');
    batch.execute('CREATE INDEX idx_project_items_project ON project_items(projectId)');
    batch.execute('CREATE INDEX idx_project_items_completed ON project_items(isCompleted)');

    // 4. Workouts
    batch.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        targetTime TEXT,
        estimatedDurationMinutes INTEGER,
        notes TEXT,
        isCurrentFocus INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    batch.execute('CREATE INDEX idx_workouts_focus ON workouts(isCurrentFocus)');

    // 5. Exercises
    batch.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        workoutId TEXT NOT NULL,
        category TEXT,
        name TEXT NOT NULL,
        sets INTEGER NOT NULL DEFAULT 3,
        repetitions INTEGER NOT NULL DEFAULT 10,
        weight REAL,
        durationSeconds INTEGER,
        notes TEXT,
        sortOrder INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (workoutId) REFERENCES workouts (id) ON DELETE CASCADE
      )
    ''');
    batch.execute('CREATE INDEX idx_exercises_workout ON exercises(workoutId)');
    batch.execute('CREATE INDEX idx_exercises_order ON exercises(sortOrder)');

    // 6. Content Items
    batch.execute('''
      CREATE TABLE content_items (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        contentType TEXT,
        duration TEXT,
        thumbnailUrl TEXT,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'Idea',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    batch.execute('CREATE INDEX idx_content_status ON content_items(status)');
    batch.execute('CREATE INDEX idx_content_created ON content_items(createdAt)');

    // 7. Notes
    batch.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        isPinned INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    batch.execute('CREATE INDEX idx_notes_pinned ON notes(isPinned)');
    batch.execute('CREATE INDEX idx_notes_created ON notes(createdAt)');

    // 8. Shopping Items
    batch.execute('''
      CREATE TABLE shopping_items (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        notes TEXT,
        isBought INTEGER NOT NULL DEFAULT 0,
        boughtAt TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    batch.execute('CREATE INDEX idx_shopping_bought ON shopping_items(isBought)');
    batch.execute('CREATE INDEX idx_shopping_created ON shopping_items(createdAt)');

    // 9. ML Intelligence Events
    batch.execute('''
      CREATE TABLE ml_events (
        id TEXT PRIMARY KEY,
        eventType TEXT NOT NULL,
        itemType TEXT,
        itemId TEXT,
        metadataJson TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
    batch.execute('CREATE INDEX idx_ml_events_type ON ml_events(eventType)');
    batch.execute('CREATE INDEX idx_ml_events_created ON ml_events(createdAt)');

    await batch.commit(noResult: true);
  }

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ml_events (
          id TEXT PRIMARY KEY,
          eventType TEXT NOT NULL,
          itemType TEXT,
          itemId TEXT,
          metadataJson TEXT,
          createdAt TEXT NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_ml_events_type ON ml_events(eventType)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_ml_events_created ON ml_events(createdAt)');
    }
  }
}
