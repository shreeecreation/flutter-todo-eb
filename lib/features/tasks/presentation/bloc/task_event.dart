import 'package:equatable/equatable.dart';
import 'package:todo_app/features/tasks/domain/entities/task_entity.dart';

sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

final class LoadTasks extends TaskEvent {
  const LoadTasks();
}

final class AddTask extends TaskEvent {
  const AddTask(this.task);
  final TaskEntity task;

  @override
  List<Object?> get props => [task];
}

final class UpdateTask extends TaskEvent {
  const UpdateTask(this.task);
  final TaskEntity task;

  @override
  List<Object?> get props => [task];
}

final class DeleteTask extends TaskEvent {
  const DeleteTask(this.taskId);
  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

final class UndoDelete extends TaskEvent {
  const UndoDelete();
}

final class ToggleTask extends TaskEvent {
  const ToggleTask(this.task);
  final TaskEntity task;

  @override
  List<Object?> get props => [task];
}

final class ReorderTasks extends TaskEvent {
  const ReorderTasks(this.tasks);
  final List<TaskEntity> tasks;

  @override
  List<Object?> get props => [tasks];
}

final class SearchTasks extends TaskEvent {
  const SearchTasks(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

final class FilterChanged extends TaskEvent {
  const FilterChanged(this.filter);
  final TaskFilter filter;

  @override
  List<Object?> get props => [filter];
}