import 'package:flutter_test/flutter_test.dart';
import 'package:burn_shut/core/database/app_database.dart';
import 'package:burn_shut/core/services/export_import_service.dart';
import 'package:burn_shut/data/repositories/sqlite_task_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_project_repository.dart';
import 'package:burn_shut/data/repositories/sqlite_shopping_repository.dart';
import 'package:burn_shut/domain/models/task.dart';
import 'package:burn_shut/domain/models/project.dart';
import 'package:burn_shut/domain/models/shopping_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ExportImportService service;
  late SqliteTaskRepository taskRepo;
  late SqliteProjectRepository projectRepo;
  late SqliteShoppingRepository shoppingRepo;

  setUp(() async {
    db = await AppDatabase.createInMemory();
    service = ExportImportService(appDatabase: db);
    taskRepo = SqliteTaskRepository(appDatabase: db);
    projectRepo = SqliteProjectRepository(appDatabase: db);
    shoppingRepo = SqliteShoppingRepository(appDatabase: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ExportImportService Tests', () {
    test('Export and Import backup cycle with replace and merge', () async {
      final now = DateTime.now();

      await taskRepo.insertTask(Task(
        id: 't-exp',
        title: 'Exported Task',
        createdAt: now,
        updatedAt: now,
      ));

      await projectRepo.insertProject(Project(
        id: 'p-exp',
        title: 'Exported Project',
        createdAt: now,
        updatedAt: now,
        items: [
          ProjectItem(
            id: 'pi-exp',
            projectId: 'p-exp',
            title: 'Sub Item 1',
            createdAt: now,
            updatedAt: now,
          ),
        ],
      ));

      await shoppingRepo.insertShoppingItem(ShoppingItem(
        id: 's-exp',
        title: 'Coffee Beans',
        createdAt: now,
        updatedAt: now,
      ));

      // 1. Export
      final jsonString = await service.exportToJsonString();
      expect(jsonString, contains('Burn Shut'));
      expect(jsonString, contains('Exported Task'));
      expect(jsonString, contains('Exported Project'));
      expect(jsonString, contains('Coffee Beans'));

      // Validate
      expect(service.validateJson(jsonString), true);
      expect(service.validateJson('{"invalid": true}'), false);

      // 2. Wipe database
      await db.resetDatabase();
      var tasks = await taskRepo.getActiveTasks();
      expect(tasks.isEmpty, true);

      // 3. Restore from backup
      final result = await service.importFromJsonString(jsonString, replace: true);
      expect(result.success, true);
      expect(result.tasksImported, 1);
      expect(result.projectsImported, 1);
      expect(result.shoppingItemsImported, 1);

      tasks = await taskRepo.getActiveTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Exported Task');

      final projects = await projectRepo.getActiveProjects();
      expect(projects.length, 1);
      expect(projects.first.items.length, 1);
      expect(projects.first.items.first.title, 'Sub Item 1');
    });
  });
}
