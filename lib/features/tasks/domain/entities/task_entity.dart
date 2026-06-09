import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high }

enum TaskFilter { all, active, completed }

class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.priority,
    required this.createdAt,
    required this.order,
    this.description,
    this.dueDate,
  });

  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int order;

  TaskEntity copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? dueDate,
    int? order,
    bool clearDueDate = false,
    bool clearDescription = false,
  }) {
    return TaskEntity(
      id: id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, isCompleted, priority, createdAt, dueDate, order];
}