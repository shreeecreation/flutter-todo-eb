import 'package:equatable/equatable.dart';
import 'package:todo_app/features/tasks/domain/entities/task_entity.dart';

sealed class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

final class TaskInitial extends TaskState {
  const TaskInitial();
}

final class TaskLoading extends TaskState {
  const TaskLoading();
}

final class TaskLoaded extends TaskState {
  const TaskLoaded({
    required this.allTasks,
    required this.filter,
    this.searchQuery = '',
    this.lastDeleted,
  });

  final List<TaskEntity> allTasks;
  final TaskFilter filter;
  final String searchQuery;
  final TaskEntity? lastDeleted;

  List<TaskEntity> get visibleTasks {
    var tasks = allTasks;

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      tasks = tasks
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                (t.description?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    return switch (filter) {
      TaskFilter.all => tasks,
      TaskFilter.active => tasks.where((t) => !t.isCompleted).toList(),
      TaskFilter.completed => tasks.where((t) => t.isCompleted).toList(),
    };
  }

  int get activeCount => allTasks.where((t) => !t.isCompleted).length;
  int get completedCount => allTasks.where((t) => t.isCompleted).length;

  TaskLoaded copyWith({
    List<TaskEntity>? allTasks,
    TaskFilter? filter,
    String? searchQuery,
    TaskEntity? lastDeleted,
    bool clearLastDeleted = false,
  }) {
    return TaskLoaded(
      allTasks: allTasks ?? this.allTasks,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      lastDeleted: clearLastDeleted ? null : (lastDeleted ?? this.lastDeleted),
    );
  }

  @override
  List<Object?> get props =>
      [allTasks, filter, searchQuery, lastDeleted];
}

final class TaskError extends TaskState {
  const TaskError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}