import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/core/extensions/context_extension.dart';
import 'package:todo_app/core/extensions/datetime_x.dart';
import 'package:todo_app/features/tasks/domain/entities/task_entity.dart';
import 'package:todo_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:todo_app/features/tasks/presentation/bloc/task_event.dart';
import 'package:todo_app/features/tasks/presentation/bloc/task_state.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/widgets/widgets.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key, this.task});
  final TaskEntity? task;

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late TaskPriority _priority;
  DateTime? _dueDate;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task?.title ?? '');
    _description =
        TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit task' : 'New task',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              _isEditing ? 'Save' : 'Add',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(
            maxLines: 2,
              controller: _title,
              hint: 'Task title',
              autofocus: true,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _description,
              hint: 'Description (optional)',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            PrioritySelector(
              value: _priority,
              onChanged: (p) => setState(() => _priority = p),
            ),
            const SizedBox(height: 24),
            _DueDateSection(
              dueDate: _dueDate,
              onChanged: (d) => setState(() => _dueDate = d),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<TaskBloc>();
    final currentOrder =
        bloc.state is TaskLoaded ? (bloc.state as TaskLoaded).allTasks.length : 0;

    final description = _description.text.trim().isEmpty
        ? null
        : _description.text.trim();

    final task = _isEditing
        ? widget.task!.copyWith(
            title: _title.text.trim(),
            description: description,
            clearDescription: description == null,
            priority: _priority,
            dueDate: _dueDate,
            clearDueDate: _dueDate == null,
          )
        : TaskEntity(
            id: const Uuid().v4(),
            title: _title.text.trim(),
            description: description,
            isCompleted: false,
            priority: _priority,
            createdAt: DateTime.now(),
            dueDate: _dueDate,
            order: currentOrder,
          );

    context
        .read<TaskBloc>()
        .add(_isEditing ? UpdateTask(task) : AddTask(task));
        context.showSnackbar(title: "Task ${_isEditing ? 'updated' : 'created'}", message: "Task '${_title.text.trim()}' has been ${_isEditing ? 'updated' : 'created'}.", error: false);

    Navigator.of(context).pop();
  }
}

class _DueDateSection extends StatelessWidget {
  const _DueDateSection({required this.dueDate, required this.onChanged});
  final DateTime? dueDate;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due date',
          style: theme.textTheme.labelMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cs.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: dueDate != null ? cs.primary : cs.outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dueDate?.toDisplayDate() ?? 'No due date',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: dueDate != null ? cs.onSurface : cs.outline,
                    ),
                  ),
                ),
                if (dueDate != null)
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: cs.outline,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) onChanged(picked);
  }
}