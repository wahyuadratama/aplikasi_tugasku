import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onTap;
  final Function(Task) onDelete; // Changed to pass Task back

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  Color get _priorityColor {
    switch (task.priority) {
      case TaskPriority.high:
        return const Color(0xFFFF6B6B);
      case TaskPriority.low:
        return const Color(0xFF4FC3F7);
      case TaskPriority.medium:
        return const Color(0xFFFFA726);
    }
  }

  @override
  Widget build(BuildContext context) {
    final overdue = task.isOverdue;
    final hasSubTasks = task.subTasks.isNotEmpty;
    final progress = task.subTasksProgress;

    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: _AnimatedCheckbox(
          value: task.isDone,
          onChanged: onToggle,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: task.isDone ? TextDecoration.lineThrough : null,
                color: task.isDone
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.onSurface,
              ),
              child: Text(task.title),
            ),
            if (hasSubTasks) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: const Color(0xFFE0E0E0),
                      color: const Color(0xFF6C63FF),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${task.subTasksDone}/${task.subTasksTotal}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _priorityColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.priority.label,
                style: TextStyle(
                  color: _priorityColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${task.deadlineLabel} • ${task.category}',
                style: TextStyle(
                  color: overdue
                      ? const Color(0xFFFF6B6B)
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: overdue ? FontWeight.w600 : null,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          onPressed: () => onDelete(task),
        ),
        onTap: onTap,
      ),
    );

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete(task);
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return true;
        }
        return false;
      },
      child: card,
    );
  }
}

class _AnimatedCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const _AnimatedCheckbox({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      button: true,
      label: 'toggle task',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onChanged == null ? null : () => onChanged!(!value),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF6C63FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: value
                    ? const Color(0xFF6C63FF)
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: AnimatedScale(
              scale: value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: const Icon(
                Icons.check_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
