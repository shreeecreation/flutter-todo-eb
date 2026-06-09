import 'package:drift/drift.dart';
import 'package:todo_app/core/error/exceptions.dart';
import 'package:todo_app/features/tasks/data/models/app_database.dart';
import 'package:todo_app/features/tasks/domain/entities/task_entity.dart';

abstract interface class TaskLocalDataSource {
  Future<List<TaskEntity>> getTasks();
  Future<void> insertTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Future<void> reorderTasks(List<TaskEntity> tasks);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  const TaskLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<TaskEntity>> getTasks() async {
    try {
      final rows = await (_db.select(_db.tasks)
            ..orderBy([(t) => OrderingTerm.asc(t.order)]))
          .get();
      return rows.map((r) => r.toEntity()).toList();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> insertTask(TaskEntity task) async {
    try {
      await _db.into(_db.tasks).insert(task.toCompanion());
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    try {
      await (_db.update(_db.tasks)
            ..where((t) => t.id.equals(task.id)))
          .write(task.toCompanion());
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await (_db.delete(_db.tasks)
            ..where((t) => t.id.equals(id)))
          .go();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> reorderTasks(List<TaskEntity> tasks) async {
    try {
      await _db.transaction(() async {
        for (var i = 0; i < tasks.length; i++) {
          await (_db.update(_db.tasks)
                ..where((t) => t.id.equals(tasks[i].id)))
              .write(TasksCompanion(order: Value(i)));
        }
      });
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}