import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/core/extensions/context_extension.dart';
import 'package:todo_app/core/theme/theme_cubit.dart';
import 'package:todo_app/core/utils/constants.dart';
import 'package:todo_app/features/tasks/domain/entities/task_entity.dart';
import 'package:todo_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:todo_app/features/tasks/presentation/bloc/task_event.dart';
import 'package:todo_app/features/tasks/presentation/bloc/task_state.dart';
import 'package:todo_app/features/tasks/presentation/pages/task_form_page.dart';
import '../../../../core/widgets/widgets.dart';
import '../widgets/sort_bottom_sheet.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskState>(
      listenWhen: (prev, curr) =>
          curr is TaskLoaded && curr.lastDeleted != null &&
          (prev is! TaskLoaded || prev.lastDeleted != curr.lastDeleted),
      listener: _onDeletedListener,
      builder: (context, state) => Scaffold(
        
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _AppBar(state: state),
        body: switch (state) {
          TaskInitial() || TaskLoading() => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          TaskError(:final message) => EmptyState(
              message: message,
              icon: Icons.error_outline_rounded,
            ),
          TaskLoaded() => _LoadedBody(state: state),
        },
        floatingActionButton: _AddButton(enabled: state is TaskLoaded),
      ),
    );
  }

  void _onDeletedListener(BuildContext context, TaskState state) {
    if (state is! TaskLoaded || state.lastDeleted == null) return;
    final title = state.lastDeleted!.title;
    final message = 'Task "$title" deleted';
    context.showSnackbar(title: title, message: message, undo: () => context.read<TaskBloc>().add(const UndoDelete()));
    //   ..hideCurrentSnackBar()
    //   ..showSnackBar(
    //     SnackBar(
    //       behavior: SnackBarBehavior.floating,
    //       margin: const EdgeInsets.all(16),
    //       shape: RoundedRectangleBorder( 
    //         borderRadius: BorderRadius.circular(12),
    //       ),
    //       content: Text(
    //         '"${state.lastDeleted!.title}" deleted',
    //         style: const TextStyle(fontSize: 14),
    //       ),
    //       duration: AppConstants.undoDeleteDuration,
    //       action: SnackBarAction(
    //         label: 'Undo',
    //         onPressed: () =>
    //             context.read<TaskBloc>().add(const UndoDelete()),
    //       ),
    //     ),
    //   );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.state});
  final TaskState state;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final loaded = state is TaskLoaded ? state as TaskLoaded : null;

    return AppBar(
      backgroundColor: cs.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.appName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (loaded != null)
            Text(
              _subtitle(loaded),
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
        ],
      ),
      actions: [
        if (loaded != null)
          IconButton(
            icon: Icon(
              Icons.sort_rounded,
              color: loaded.currentSort != null ? cs.primary : null,
            ),
            tooltip: 'Sort',
            onPressed: () => _openSort(context, loaded),
          ),

          IconButton(
            icon: const Icon(Icons.sunny),
            tooltip: 'Mode',
            onPressed: () => context.read<ThemeCubit>().toggleTheme()
          ),
      ],
    );
  }

  String _subtitle(TaskLoaded state) {
    final total = state.allTasks.length;
    if (total == 0) return 'No tasks yet';
    return '${state.completedCount} of $total completed';
  }

  Future<void> _openSort(BuildContext context, TaskLoaded state) async {
    final result = await SortBottomSheet.show(
      context,
      current: state.currentSort,
    );
    if (!context.mounted) return;
    context.read<TaskBloc>().add(ApplySort(result));
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state});
  final TaskLoaded state;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          _SearchAndFilter(state: state),
          Expanded(child: _TaskList(state: state)),
        ],
      ),
    );
  }
}

class _SearchAndFilter extends StatelessWidget {
  const _SearchAndFilter({required this.state});
  final TaskLoaded state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          AppTextField(
            hint: 'Search tasks…',
            prefix: const Icon(Icons.search_rounded, size: 20),
            onChanged: (q) =>
                context.read<TaskBloc>().add(SearchTasks(q)),
          ),
          const SizedBox(height: 10),
          TaskFilterBar(
            current: state.filter,
            onChanged: (f) =>
                context.read<TaskBloc>().add(FilterChanged(f)),
            allCount: state.allTasks.length,
            activeCount: state.activeCount,
            completedCount: state.completedCount,
          ),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.state});
  final TaskLoaded state;

  @override
  Widget build(BuildContext context) {
    final tasks = state.visibleTasks;

    if (tasks.isEmpty) {
      return EmptyState(
        message: state.searchQuery.isNotEmpty
            ? 'No results for "${state.searchQuery}"'
            : 'Nothing here yet',
        icon: Icons.check_circle_outline_rounded,
      );
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<TaskBloc>().add(const LoadTasks()),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        proxyDecorator: _proxyDecorator,
        itemCount: tasks.length,
        onReorder: (oldIndex, newIndex) =>
            _onReorder(context, oldIndex, newIndex, state),
        itemBuilder: (context, i) {
          final task = tasks[i];
          return TaskListItem(
            key: ValueKey(task.id),
            task: task,
            index: i,
            onToggle: () =>
                context.read<TaskBloc>().add(ToggleTask(task)),
            onTap: () => _openForm(context, task),
            onDelete: () =>
                context.read<TaskBloc>().add(DeleteTask(task.id)),
          );
        },
      ),
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) => Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(14),
        shadowColor: Colors.black26,
        child: child,
      ),
      child: child,
    );
  }

  void _onReorder(
    BuildContext context,
    int oldIndex,
    int newIndex,
    TaskLoaded state,
  ) {
    if (newIndex > oldIndex) newIndex--;
    final reordered = [...state.allTasks];
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    final reindexed = reordered
        .asMap()
        .entries
        .map((e) => e.value.copyWith(order: e.key))
        .toList();

    context.read<TaskBloc>().add(ReorderTasks(reindexed));
  }

  void _openForm(BuildContext context, TaskEntity task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TaskBloc>(),
          child: TaskFormPage(task: task),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.enabled});
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: enabled ? () => _openForm(context) : null,
      icon: const Icon(Icons.add_rounded),
      label: const Text('New task'),
      elevation: 2,
    );
  }

  void _openForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TaskBloc>(),
          child: const TaskFormPage(),
        ),
      ),
    );
  }
}