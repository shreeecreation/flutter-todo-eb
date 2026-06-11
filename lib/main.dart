import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/core/di/injection_container.dart';
import 'package:todo_app/core/splash_page.dart';
import 'package:todo_app/core/theme/theme_state.dart';
import 'package:todo_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:todo_app/features/tasks/presentation/bloc/task_event.dart';

import 'core/theme/theme_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(BlocProvider<ThemeCubit>(
    create: (_) => ThemeCubit(),
    child: const TodoApp(),
  ));
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Tasks',
          debugShowCheckedModeBanner: false,
          theme: state.themeData,
          home: BlocProvider(
            create: (_) => sl<TaskBloc>()..add(const LoadTasks()),
            child: const SplashPage(),
          ),
        );
      },
    );
  }
}
