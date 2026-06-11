import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/tasks/domain/entities/task_entity.dart';
import 'package:todo_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:todo_app/features/tasks/domain/usecases/task_usecases.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository repo;

  final task = TaskEntity(
    id: 'test-1',
    title: 'Write unit tests',
    isCompleted: false,
    priority: TaskPriority.medium,
    createdAt: DateTime(2024),
    order: 0,
  );

  setUp(() => repo = MockTaskRepository());

  group('GetTasksUseCase', () {
    test('returns list from repository', () async {
      when(() => repo.getTasks()).thenAnswer((_) async => [task]);

      final result = await GetTasksUseCase(repo)();

      expect(result, [task]);
      verify(() => repo.getTasks()).called(1);
    });

    test('returns empty list when no tasks', () async {
      when(() => repo.getTasks()).thenAnswer((_) async => []);

      final result = await GetTasksUseCase(repo)();

      expect(result, isEmpty);
    });
  });

  group('AddTaskUseCase', () {
    test('delegates to repository', () async {
      when(() => repo.addTask(task)).thenAnswer((_) async {});

      await AddTaskUseCase(repo)(task);

      verify(() => repo.addTask(task)).called(1);
    });
  });

  group('UpdateTaskUseCase', () {
    test('passes updated entity to repository', () async {
      final updated = task.copyWith(isCompleted: true);
      when(() => repo.updateTask(updated)).thenAnswer((_) async {});

      await UpdateTaskUseCase(repo)(updated);

      verify(() => repo.updateTask(updated)).called(1);
    });
  });

  group('DeleteTaskUseCase', () {
    test('delegates id to repository', () async {
      when(() => repo.deleteTask('test-1')).thenAnswer((_) async {});

      await DeleteTaskUseCase(repo)('test-1');

      verify(() => repo.deleteTask('test-1')).called(1);
    });
  });

  group('ReorderTasksUseCase', () {
    test('passes reordered list to repository', () async {
      final tasks = [task, task.copyWith(order: 1)];
      when(() => repo.reorderTasks(tasks)).thenAnswer((_) async {});

      await ReorderTasksUseCase(repo)(tasks);

      verify(() => repo.reorderTasks(tasks)).called(1);
    });
  });
}