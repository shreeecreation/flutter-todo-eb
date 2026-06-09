import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:todo_app/features/tasks/domain/entities/task_entity.dart';

part 'app_database.g.dart';

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get priority => textEnum<TaskPriority>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get order => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() =>
      driftDatabase(name: 'todo_db');
}

extension TaskRowMapper on Task {
  TaskEntity toEntity() => TaskEntity(
        id: id,
        title: title,
        description: description,
        isCompleted: isCompleted,
        priority: priority,
        createdAt: createdAt,
        dueDate: dueDate,
        order: order,
      );
}

extension TaskEntityMapper on TaskEntity {
  TasksCompanion toCompanion() => TasksCompanion(
        id: Value(id),
        title: Value(title),
        description: Value(description),
        isCompleted: Value(isCompleted),
        priority: Value(priority),
        createdAt: Value(createdAt),
        dueDate: Value(dueDate),
        order: Value(order),
      );
}