import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/core/extensions/sort_extension.dart';
import 'package:todo_app/features/tasks/domain/entities/task_entity.dart';
import 'package:todo_app/features/tasks/domain/usecases/task_usecases.dart';
import 'package:todo_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:todo_app/features/tasks/presentation/bloc/task_event.dart';
import 'package:todo_app/features/tasks/presentation/bloc/task_state.dart';

class MockGetTasks extends Mock implements GetTasksUseCase {}
class MockAddTask extends Mock implements AddTaskUseCase {}
class MockUpdateTask extends Mock implements UpdateTaskUseCase {}
class MockDeleteTask extends Mock implements DeleteTaskUseCase {}
class MockReorderTasks extends Mock implements ReorderTasksUseCase {}

// shared fixtures
final tTask = TaskEntity(
  id: 'bloc-1',
  title: 'Test task',
  isCompleted: false,
  priority: TaskPriority.medium,
  createdAt: DateTime(2024),
  order: 0,
);

final tTask2 = TaskEntity(
  id: 'bloc-2',
  title: 'Second task',
  isCompleted: true,
  priority: TaskPriority.high,
  createdAt: DateTime(2024, 1, 2),
  order: 1,
);

void main() {
  late MockGetTasks getTasks;
  late MockAddTask addTask;
  late MockUpdateTask updateTask;
  late MockDeleteTask deleteTask;
  late MockReorderTasks reorderTasks;

  TaskBloc buildBloc() => TaskBloc(
        getTasks: getTasks,
        addTask: addTask,
        updateTask: updateTask,
        deleteTask: deleteTask,
        reorderTasks: reorderTasks,
      );

  setUp(() {
    getTasks = MockGetTasks();
    addTask = MockAddTask();
    updateTask = MockUpdateTask();
    deleteTask = MockDeleteTask();
    reorderTasks = MockReorderTasks();
  });

  // ─── LoadTasks ───────────────────────────────────────────────
  group('LoadTasks', () {
    blocTest<TaskBloc, TaskState>(
      'emits [Loading, Loaded] on success',
      build: buildBloc,
      setUp: () =>
          when(() => getTasks()).thenAnswer((_) async => [tTask]),
      act: (b) => b.add(const LoadTasks()),
      expect: () => [
        const TaskLoading(),
        TaskLoaded(allTasks: [tTask], filter: TaskFilter.all),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [Loading, Error] on CacheFailure',
      build: buildBloc,
      setUp: () =>
          when(() => getTasks()).thenThrow(const CacheFailure('db error')),
      act: (b) => b.add(const LoadTasks()),
      expect: () => [
        const TaskLoading(),
        const TaskError('db error'),
      ],
    );
  });

  // ─── AddTask ─────────────────────────────────────────────────
  group('AddTask', () {
    blocTest<TaskBloc, TaskState>(
      'optimistically appends task then persists',
      build: buildBloc,
      setUp: () =>
          when(() => addTask(tTask)).thenAnswer((_) async {}),
      seed: () => const TaskLoaded(allTasks: [], filter: TaskFilter.all),
      act: (b) => b.add(AddTask(tTask)),
      expect: () => [
        TaskLoaded(allTasks: [tTask], filter: TaskFilter.all),
      ],
      verify: (_) => verify(() => addTask(tTask)).called(1),
    );

    blocTest<TaskBloc, TaskState>(
      'rolls back on CacheFailure',
      build: buildBloc,
      setUp: () =>
          when(() => addTask(tTask)).thenThrow(const CacheFailure()),
      seed: () => const TaskLoaded(allTasks: [], filter: TaskFilter.all),
      act: (b) => b.add(AddTask(tTask)),
      expect: () => [
        TaskLoaded(allTasks: [tTask], filter: TaskFilter.all), // optimistic
        const TaskLoaded(allTasks: [], filter: TaskFilter.all), // rollback
        const TaskError('Local storage error'),
      ],
    );
  });

  // ─── ToggleTask ───────────────────────────────────────────────
  group('ToggleTask', () {
    blocTest<TaskBloc, TaskState>(
      'flips isCompleted from false to true',
      build: buildBloc,
      setUp: () {
        final toggled = tTask.copyWith(isCompleted: true);
        when(() => updateTask(toggled)).thenAnswer((_) async {});
      },
      seed: () => TaskLoaded(allTasks: [tTask], filter: TaskFilter.all),
      act: (b) => b.add(ToggleTask(tTask)),
      verify: (b) {
        final loaded = b.state as TaskLoaded;
        expect(loaded.allTasks.first.isCompleted, isTrue);
      },
    );
  });

  // ─── DeleteTask + UndoDelete ──────────────────────────────────
  group('DeleteTask', () {
    blocTest<TaskBloc, TaskState>(
      'removes task and stores lastDeleted',
      build: buildBloc,
      seed: () => TaskLoaded(allTasks: [tTask], filter: TaskFilter.all),
      act: (b) => b.add(DeleteTask(tTask.id)),
      expect: () => [
        TaskLoaded(
          allTasks: const [],
          filter: TaskFilter.all,
          lastDeleted: tTask,
        ),
      ],
    );
  });

  group('UndoDelete', () {
    blocTest<TaskBloc, TaskState>(
      'restores lastDeleted back into allTasks',
      build: buildBloc,
      seed: () => TaskLoaded(
        allTasks: const [],
        filter: TaskFilter.all,
        lastDeleted: tTask,
      ),
      act: (b) => b.add(const UndoDelete()),
      expect: () => [
        TaskLoaded(allTasks: [tTask], filter: TaskFilter.all),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'does nothing when lastDeleted is null',
      build: buildBloc,
      seed: () => TaskLoaded(allTasks: [tTask], filter: TaskFilter.all),
      act: (b) => b.add(const UndoDelete()),
      expect: () => <TaskState>[],
    );
  });

  // ─── SearchTasks ──────────────────────────────────────────────
  group('SearchTasks', () {
    blocTest<TaskBloc, TaskState>(
      'updates searchQuery without touching allTasks',
      build: buildBloc,
      seed: () =>
          TaskLoaded(allTasks: [tTask, tTask2], filter: TaskFilter.all),
      act: (b) => b.add(const SearchTasks('second')),
      verify: (b) {
        final loaded = b.state as TaskLoaded;
        expect(loaded.searchQuery, 'second');
        expect(loaded.allTasks.length, 2);       // allTasks untouched
        expect(loaded.visibleTasks.length, 1);   // filter applied
        expect(loaded.visibleTasks.first.id, 'bloc-2');
      },
    );

    blocTest<TaskBloc, TaskState>(
      'empty query shows all tasks',
      build: buildBloc,
      seed: () => TaskLoaded(
        allTasks: [tTask, tTask2],
        filter: TaskFilter.all,
        searchQuery: 'second',
      ),
      act: (b) => b.add(const SearchTasks('')),
      verify: (b) {
        final loaded = b.state as TaskLoaded;
        expect(loaded.visibleTasks.length, 2);
      },
    );
  });

  // ─── FilterChanged ────────────────────────────────────────────
  group('FilterChanged', () {
    blocTest<TaskBloc, TaskState>(
      'active filter shows only incomplete tasks',
      build: buildBloc,
      seed: () =>
          TaskLoaded(allTasks: [tTask, tTask2], filter: TaskFilter.all),
      act: (b) => b.add(const FilterChanged(TaskFilter.active)),
      verify: (b) {
        final loaded = b.state as TaskLoaded;
        expect(loaded.visibleTasks.every((t) => !t.isCompleted), isTrue);
        expect(loaded.visibleTasks.length, 1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'completed filter shows only completed tasks',
      build: buildBloc,
      seed: () =>
          TaskLoaded(allTasks: [tTask, tTask2], filter: TaskFilter.all),
      act: (b) => b.add(const FilterChanged(TaskFilter.completed)),
      verify: (b) {
        final loaded = b.state as TaskLoaded;
        expect(loaded.visibleTasks.every((t) => t.isCompleted), isTrue);
      },
    );
  });

  // ─── ApplySort ────────────────────────────────────────────────
  group('ApplySort', () {
    final highTask = tTask.copyWith(priority: TaskPriority.high);
    final lowTask = tTask2.copyWith(isCompleted: false, priority: TaskPriority.low);

    blocTest<TaskBloc, TaskState>(
      'sorts by priority high to low',
      build: buildBloc,
      seed: () => TaskLoaded(
        allTasks: [lowTask, highTask],
        filter: TaskFilter.all,
      ),
      act: (b) => b.add(const ApplySort(SortOption.priorityHigh)),
      verify: (b) {
        final loaded = b.state as TaskLoaded;
        expect(loaded.allTasks.first.priority, TaskPriority.high);
        expect(loaded.currentSort, SortOption.priorityHigh);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'clearSort restores original order',
      build: buildBloc,
      seed: () => TaskLoaded(
        allTasks: [lowTask, highTask],
        filter: TaskFilter.all,
        currentSort: SortOption.priorityHigh,
      ),
      act: (b) => b.add(const ApplySort(null)),
      verify: (b) {
        final loaded = b.state as TaskLoaded;
        expect(loaded.currentSort, isNull);
      },
    );
  });
}