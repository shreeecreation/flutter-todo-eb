import 'package:todo_app/features/tasks/domain/entities/task_entity.dart';

abstract interface class TaskRepository {
  Future<List<TaskEntity>> getTasks();
  Future<void> addTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Future<void> reorderTasks(List<TaskEntity> tasks);
}