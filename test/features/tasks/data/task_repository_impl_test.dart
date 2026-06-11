import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/core/error/exceptions.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:todo_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:todo_app/features/tasks/domain/entities/task_entity.dart';

class MockTaskLocalDataSource extends Mock implements TaskLocalDataSource {}

void main() {
  late MockTaskLocalDataSource dataSource;
  late TaskRepositoryImpl repo;

  final task = TaskEntity(
    id: 'repo-1',
    title: 'Test repo',
    isCompleted: false,
    priority: TaskPriority.low,
    createdAt: DateTime(2024, 1, 1),
    order: 0,
  );

  setUp(() {
    dataSource = MockTaskLocalDataSource();
    repo = TaskRepositoryImpl(dataSource);
  });

  group('getTasks', () {
    test('returns tasks from datasource on success', () async {
      when(() => dataSource.getTasks()).thenAnswer((_) async => [task]);

      final result = await repo.getTasks();

      expect(result, [task]);
    });

    test('throws CacheFailure when datasource throws CacheException', () {
      when(() => dataSource.getTasks())
          .thenThrow(const CacheException('db read failed'));

      expect(
        () => repo.getTasks(),
        throwsA(isA<CacheFailure>()),
      );
    });
  });

  group('addTask', () {
    test('delegates to datasource', () async {
      when(() => dataSource.insertTask(task)).thenAnswer((_) async {});

      await repo.addTask(task);

      verify(() => dataSource.insertTask(task)).called(1);
    });

    test('throws CacheFailure on datasource error', () {
      when(() => dataSource.insertTask(task))
          .thenThrow(const CacheException());

      expect(() => repo.addTask(task), throwsA(isA<CacheFailure>()));
    });
  });

  group('updateTask', () {
    test('delegates to datasource', () async {
      when(() => dataSource.updateTask(task)).thenAnswer((_) async {});

      await repo.updateTask(task);

      verify(() => dataSource.updateTask(task)).called(1);
    });

    test('throws CacheFailure on datasource error', () {
      when(() => dataSource.updateTask(task))
          .thenThrow(const CacheException());

      expect(() => repo.updateTask(task), throwsA(isA<CacheFailure>()));
    });
  });

  group('deleteTask', () {
    test('delegates id to datasource', () async {
      when(() => dataSource.deleteTask('repo-1')).thenAnswer((_) async {});

      await repo.deleteTask('repo-1');

      verify(() => dataSource.deleteTask('repo-1')).called(1);
    });

    test('throws CacheFailure on datasource error', () {
      when(() => dataSource.deleteTask(any()))
          .thenThrow(const CacheException());

      expect(
        () => repo.deleteTask('repo-1'),
        throwsA(isA<CacheFailure>()),
      );
    });
  });
}