import 'package:todo_app/core/error/exceptions.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:todo_app/features/tasks/domain/entities/task_entity.dart';
import 'package:todo_app/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._dataSource);

  final TaskLocalDataSource _dataSource;

  @override
  Future<List<TaskEntity>> getTasks() async {
    try {
      return await _dataSource.getTasks();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    try {
      await _dataSource.insertTask(task);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    try {
      await _dataSource.updateTask(task);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _dataSource.deleteTask(id);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> reorderTasks(List<TaskEntity> tasks) async {
    try {
      await _dataSource.reorderTasks(tasks);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }
}