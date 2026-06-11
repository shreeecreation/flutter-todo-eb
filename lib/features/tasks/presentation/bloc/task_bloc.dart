import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/core/extensions/sort_extension.dart';
import 'package:todo_app/core/utils/constants.dart';
import 'package:todo_app/features/tasks/domain/usecases/task_usecases.dart';
import 'package:todo_app/features/tasks/presentation/bloc/task_event.dart';
import 'package:todo_app/features/tasks/presentation/bloc/task_state.dart';

import '../../domain/entities/task_entity.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({
    required GetTasksUseCase getTasks,
    required AddTaskUseCase addTask,
    required UpdateTaskUseCase updateTask,
    required DeleteTaskUseCase deleteTask,
    required ReorderTasksUseCase reorderTasks,
  })  : _getTasks = getTasks,
        _addTask = addTask,
        _updateTask = updateTask,
        _deleteTask = deleteTask,
        _reorderTasks = reorderTasks,
        super(const TaskInitial()) {
    on<LoadTasks>(_onLoad);
    on<AddTask>(_onAdd);
    on<UpdateTask>(_onUpdate);
    on<DeleteTask>(_onDelete);
    on<UndoDelete>(_onUndoDelete);
    on<ToggleTask>(_onToggle);
    on<ReorderTasks>(_onReorder);
    on<SearchTasks>(_onSearch);
    on<FilterChanged>(_onFilterChanged);
    on<ApplySort>(_onApplySort);
    on<ClearLastDeleted>(_onClearLastDeleted);

  }

  final GetTasksUseCase _getTasks;
  final AddTaskUseCase _addTask;
  final UpdateTaskUseCase _updateTask;
  final DeleteTaskUseCase _deleteTask;
  final ReorderTasksUseCase _reorderTasks;

  Timer? _undoTimer;

  Future<void> _onLoad(LoadTasks event, Emitter<TaskState> emit) async {
    emit(const TaskLoading());
    try {
      final tasks = await _getTasks();
      emit(TaskLoaded(
        allTasks: tasks,
        filter: TaskFilter.all,
      ));
    } on CacheFailure catch (e) {
      emit(TaskError(e.message));
    } catch (_) {
      emit(const TaskError('Unexpected error loading tasks'));
    }
  }

  Future<void> _onAdd(AddTask event, Emitter<TaskState> emit) async {
    final current = state;
    if (current is! TaskLoaded) return;

    // optimistic update
    emit(current.copyWith(allTasks: [...current.allTasks, event.task]));

    try {
      await _addTask(event.task);
    } on CacheFailure catch (e) {
      emit(current);
      emit(TaskError(e.message));
    }
  }

  Future<void> _onUpdate(UpdateTask event, Emitter<TaskState> emit) async {
    final current = state;
    if (current is! TaskLoaded) return;

    final updated = current.allTasks
        .map((t) => t.id == event.task.id ? event.task : t)
        .toList();

    // optimistic update
    emit(current.copyWith(allTasks: updated));

    try {
      await _updateTask(event.task);
    } on CacheFailure catch (e) {
      emit(current);
      emit(TaskError(e.message));
    }
  }

  Future<void> _onUndoDelete(
    UndoDelete event,
    Emitter<TaskState> emit,
  ) async {
    final current = state;
    if (current is! TaskLoaded || current.lastDeleted == null) return;

    _undoTimer?.cancel();

    final restored = [...current.allTasks, current.lastDeleted!]
      ..sort((a, b) => a.order.compareTo(b.order));

    emit(current.copyWith(allTasks: restored, clearLastDeleted: true));
  }

  Future<void> _onToggle(ToggleTask event, Emitter<TaskState> emit) async {
    add(UpdateTask(event.task.copyWith(isCompleted: !event.task.isCompleted)));
  }

  Future<void> _onReorder(ReorderTasks event, Emitter<TaskState> emit) async {
    final current = state;
    if (current is! TaskLoaded) return;

    emit(current.copyWith(allTasks: event.tasks));

    try {
      await _reorderTasks(event.tasks);
    } on CacheFailure catch (e) {
      emit(current);
      emit(TaskError(e.message));
    }
  }

  void _onSearch(SearchTasks event, Emitter<TaskState> emit) {
    final current = state;
    if (current is! TaskLoaded) return;
    emit(current.copyWith(searchQuery: event.query));
  }

  void _onFilterChanged(FilterChanged event, Emitter<TaskState> emit) {
    final current = state;
    if (current is! TaskLoaded) return;
    emit(current.copyWith(filter: event.filter));
  }

  void _onApplySort(ApplySort event, Emitter<TaskState> emit) {
  final current = state;
  if (current is! TaskLoaded) return;

  if (event.option == null) {
    final restored = [...current.allTasks]
      ..sort((a, b) => a.order.compareTo(b.order));
    emit(current.copyWith(allTasks: restored, clearSort: true));
    return;
  }

  final sorted = event.option!.apply(current.allTasks);
  emit(current.copyWith(allTasks: sorted, currentSort: event.option));
}

Future<void> _onDelete(DeleteTask event, Emitter<TaskState> emit) async {
  final current = state;
  if (current is! TaskLoaded) return;

  final deleted = current.allTasks.firstWhere((t) => t.id == event.taskId);
  final remaining =
      current.allTasks.where((t) => t.id != event.taskId).toList();

  emit(current.copyWith(allTasks: remaining, lastDeleted: deleted));

  _undoTimer?.cancel();
  _undoTimer = Timer(AppConstants.undoDeleteDuration, () async {
    try {
      await _deleteTask(deleted.id);
    } on CacheFailure {
      // swallow silently
    } finally {
      add(const ClearLastDeleted());
    }
  });
}
void _onClearLastDeleted(
  ClearLastDeleted event,
  Emitter<TaskState> emit,
) {
  final current = state;
  if (current is! TaskLoaded) return;
  emit(current.copyWith(clearLastDeleted: true));
}

  @override
  Future<void> close() {
    _undoTimer?.cancel();
    return super.close();
  }
}