import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

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
        leading: Checkbox(
          value: task.isDone,
          activeColor: const Color(0xFF6C63FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          onChanged: onToggle,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: task.isDone ? TextDecoration.lineThrough : null,
                color: task.isDone
                    ? const Color(0xFF8A8A9E)
                    : const Color(0xFF1E1E2E),
              ),
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
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8A8A9E),
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
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _priorityColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${task.deadlineLabel} • ${task.category} • ${task.priority.label}',
                style: TextStyle(
                  color: overdue
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF8A8A9E),
                  fontSize: 12,
                  fontWeight: overdue ? FontWeight.w600 : null,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFF8A8A9E)),
          onPressed: onDelete,
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
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF4FC3F7),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left = delete
          return true;
        }
        return false;
      },
      child: card,
    );
  }
}
