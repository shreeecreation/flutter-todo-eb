import 'package:get_it/get_it.dart';
import 'package:todo_app/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:todo_app/features/tasks/data/models/app_database.dart';
import 'package:todo_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:todo_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:todo_app/features/tasks/domain/usecases/task_usecases.dart';
import 'package:todo_app/features/tasks/presentation/bloc/task_bloc.dart';

final sl = GetIt.instance;

void configureDependencies() {
  _registerDatabase();
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerBloc();
}

void _registerDatabase() {
  sl.registerLazySingleton<AppDatabase>(AppDatabase.new);
}

void _registerDataSources() {
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(sl()),
  );
}

void _registerRepositories() {
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl()),
  );
}

void _registerUseCases() {
  sl
    ..registerLazySingleton(() => GetTasksUseCase(sl()))
    ..registerLazySingleton(() => AddTaskUseCase(sl()))
    ..registerLazySingleton(() => UpdateTaskUseCase(sl()))
    ..registerLazySingleton(() => DeleteTaskUseCase(sl()))
    ..registerLazySingleton(() => ReorderTasksUseCase(sl()));
}

void _registerBloc() {
  sl.registerFactory(
    () => TaskBloc(
      getTasks: sl(),
      addTask: sl(),
      updateTask: sl(),
      deleteTask: sl(),
      reorderTasks: sl(),
    ),
  );
}