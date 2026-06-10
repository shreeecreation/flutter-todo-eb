import 'package:flutter/material.dart';
import 'package:todo_app/features/tasks/domain/entities/task_entity.dart';

import 'due_date_label.dart';
import 'priority_badge.dart';

class TaskListItem extends StatelessWidget {
  const TaskListItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
    required this.index,
  });

  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: cs.outlineVariant.withOpacity(0.4),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(4, 10, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _PriorityStrip(priority: task.priority),
                const SizedBox(width: 4),
                _Checkbox(isCompleted: task.isCompleted, onToggle: onToggle),
                const SizedBox(width: 4),
                Expanded(child: _TaskContent(task: task, theme: theme)),
                const SizedBox(width: 8),
                _Actions(onDelete: onDelete, index: index, cs: cs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriorityStrip extends StatelessWidget {
  const _PriorityStrip({required this.priority});
  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      TaskPriority.high => Colors.red,
      TaskPriority.medium => Colors.orange,
      TaskPriority.low => Colors.green,
    };
    return Container(
      width: 3,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.7),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.isCompleted, required this.onToggle});
  final bool isCompleted;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22,
        height: 22,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? cs.primary : Colors.transparent,
          border: Border.all(
            color: isCompleted ? cs.primary : cs.outline.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: isCompleted
            ? Icon(Icons.check_rounded, size: 14, color: cs.onPrimary)
            : null,
      ),
    );
  }
}

class _TaskContent extends StatelessWidget {
  const _TaskContent({required this.task, required this.theme});
  final TaskEntity task;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration:
                task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? theme.colorScheme.outline
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (task.description != null && task.description!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            task.description!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (task.dueDate != null) ...[
          const SizedBox(height: 4),
          DueDateLabel(dueDate: task.dueDate!),
        ],
        if (!task.isCompleted) ...[
          const SizedBox(height: 4),
          PriorityBadge(priority: task.priority),
        ],
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.onDelete,
    required this.index,
    required this.cs,
  });
  final VoidCallback onDelete;
  final int index;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onDelete,
          child: Icon(
            Icons.delete_outline_rounded,
            size: 18,
            color: cs.error.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 10),
        ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_indicator_rounded,
            size: 18,
            color: cs.outlineVariant,
          ),
        ),
      ],
    );
  }
}