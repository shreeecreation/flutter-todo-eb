import 'package:todo_app/features/tasks/domain/entities/task_entity.dart';
import 'package:todo_app/features/tasks/domain/repositories/task_repository.dart';

class GetTasksUseCase {
  const GetTasksUseCase(this._repo);
  final TaskRepository _repo;

  Future<List<TaskEntity>> call() => _repo.getTasks();
}

class AddTaskUseCase {
  const AddTaskUseCase(this._repo);
  final TaskRepository _repo;

  Future<void> call(TaskEntity task) => _repo.addTask(task);
}

class UpdateTaskUseCase {
  const UpdateTaskUseCase(this._repo);
  final TaskRepository _repo;

  Future<void> call(TaskEntity task) => _repo.updateTask(task);
}

class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._repo);
  final TaskRepository _repo;

  Future<void> call(String id) => _repo.deleteTask(id);
}

class ReorderTasksUseCase {
  const ReorderTasksUseCase(this._repo);
  final TaskRepository _repo;

  Future<void> call(List<TaskEntity> tasks) => _repo.reorderTasks(tasks);
}