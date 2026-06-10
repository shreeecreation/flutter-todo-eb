import 'package:flutter/material.dart';
import 'package:todo_app/core/extensions/datetime_x.dart';

class DueDateLabel extends StatelessWidget {
  const DueDateLabel({super.key, required this.dueDate});

  final DateTime dueDate;

  @override
  Widget build(BuildContext context) {
    final isOverdue = dueDate.isOverdue;
    final color = isOverdue
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          dueDate.toDisplayDate(),
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: isOverdue ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}