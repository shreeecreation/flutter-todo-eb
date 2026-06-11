import 'package:flutter/material.dart';
import 'package:todo_app/features/tasks/domain/entities/task_entity.dart';

enum SortOption { dateAsc, dateDesc, priorityHigh, priorityLow, createdAt }

extension SortOptionX on SortOption {
  String get label => switch (this) {
        SortOption.dateAsc => 'Due date — earliest first',
        SortOption.dateDesc => 'Due date — latest first',
        SortOption.priorityHigh => 'Priority — high to low',
        SortOption.priorityLow => 'Priority — low to high',
        SortOption.createdAt => 'Date created',
      };

  IconData get icon => switch (this) {
        SortOption.dateAsc => Icons.arrow_upward_rounded,
        SortOption.dateDesc => Icons.arrow_downward_rounded,
        SortOption.priorityHigh => Icons.keyboard_double_arrow_up_rounded,
        SortOption.priorityLow => Icons.keyboard_double_arrow_down_rounded,
        SortOption.createdAt => Icons.history_rounded,
      };

  List<TaskEntity> apply(List<TaskEntity> tasks) {
    final sorted = [...tasks];
    switch (this) {
      case SortOption.dateAsc:
        sorted.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      case SortOption.dateDesc:
        sorted.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return b.dueDate!.compareTo(a.dueDate!);
        });
      case SortOption.priorityHigh:
        sorted.sort(
          (a, b) => b.priority.index.compareTo(a.priority.index),
        );
      case SortOption.priorityLow:
        sorted.sort(
          (a, b) => a.priority.index.compareTo(b.priority.index),
        );
      case SortOption.createdAt:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return sorted;
  }
}