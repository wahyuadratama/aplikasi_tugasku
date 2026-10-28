import 'package:flutter/material.dart';

import '../models/task.dart';
import 'task_storage.dart';

class RecurringService {
  /// Generate tugas berulang yang belum ada untuk hari ini.
  /// Dipanggil saat app startup atau refresh.
  static Future<void> generateRecurringTasks() async {
    try {
      final tasks = await TaskStorage.loadTasks();
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      final newTasks = <Task>[];

      for (final task in tasks) {
        if (task.recurrence == RecurrenceType.none) continue;

        // Skip jika sudah ada tugas untuk hari ini
        if (task.deadline == todayDate && !task.isDone) continue;

        // Skip jika sudah lewat end date
        if (task.recurrenceEndDate != null &&
            todayDate.isAfter(task.recurrenceEndDate!)) {
          continue;
        }

        // Generate tugas baru untuk hari ini
        final newDeadline = _getNextDeadline(task, todayDate);
        if (newDeadline == null) continue;

        final newTask = Task(
          id: _generatedId(),
          title: task.title,
          description: task.description,
          deadline: newDeadline,
          priority: task.priority,
          category: task.category,
          reminder: task.reminder,
          recurrence: task.recurrence,
          recurrenceEndDate: task.recurrenceEndDate,
        );

        newTasks.add(newTask);
      }

      if (newTasks.isNotEmpty) {
        final allTasks = [...tasks, ...newTasks];
        await TaskStorage.saveTasks(allTasks);
        debugPrint('TugasKu: ${newTasks.length} tugas berulang dibuat');
      }
    } catch (e) {
      debugPrint('TugasKu: gagal generate recurring tasks: $e');
    }
  }

  /// Hitung deadline berikutnya untuk tugas berulang.
  static DateTime? _getNextDeadline(Task task, DateTime today) {
    final lastDeadline = task.deadline;
    if (lastDeadline == null) return today;

    switch (task.recurrence) {
      case RecurrenceType.none:
        return null;
      case RecurrenceType.daily:
        return today;
      case RecurrenceType.weekly:
        // Hari yang sama minggu depan
        return today.add(const Duration(days: 7));
      case RecurrenceType.monthly:
        // Tanggal yang sama bulan depan
        final nextMonth = today.month == 12
            ? DateTime(today.year + 1, 1, today.day)
            : DateTime(today.year, today.month + 1, today.day);
        return nextMonth;
      case RecurrenceType.yearly:
        // Tanggal yang sama tahun depan
        return DateTime(today.year + 1, today.month, today.day);
    }
  }

  static String _generatedId() =>
      'task-${DateTime.now().microsecondsSinceEpoch}';
}
