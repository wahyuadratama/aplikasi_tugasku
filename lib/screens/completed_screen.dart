// Layar Tugas Selesai: daftar tugas yang sudah dicentang.
// Centang lagi untuk mengembalikan ke Beranda, ikon hapus untuk menghapus.
import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/notification_service.dart';
import '../services/task_storage.dart';
import '../utils/app_router.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class CompletedScreen extends StatefulWidget {
  final bool showAppBar;
  const CompletedScreen({super.key, this.showAppBar = true});

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  List<Task> _done = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await TaskStorage.loadTasks();
    if (!mounted) return;
    setState(() => _done = all.where((t) => t.isDone).toList());
  }

  Future<void> _toggle(Task task, bool? value) async {
    final all = await TaskStorage.loadTasks();
    final i = all.indexWhere((t) => t.id == task.id);
    if (i >= 0) {
      all[i] = task.copyWith(isDone: value ?? false);
      await TaskStorage.saveTasks(all);
    }
    // Batalkan reminder kalau dikembalikan ke aktif
    if (value == false) {
      if (task.reminder && task.deadline != null) {
        await NotificationService.scheduleReminder(task.copyWith(isDone: false));
      }
    } else {
      await NotificationService.cancelReminder(task.id);
    }
    if (!mounted) return;
    _load();
  }

  Future<void> _delete(Task task) async {
    final all = await TaskStorage.loadTasks();
    all.removeWhere((t) => t.id == task.id);
    await TaskStorage.saveTasks(all);
    await NotificationService.cancelReminder(task.id);
    if (!mounted) return;
    _load();
    
    // Show undo snackbar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tugas dihapus'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () async {
            final all = await TaskStorage.loadTasks();
            all.add(task);
            await TaskStorage.saveTasks(all);
            if (!mounted) return;
            _load();
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Edit tugas selesai: ubah datanya lalu simpan ke storage.
  Future<void> _openEditor(Task task) async {
    final result = await Navigator.push<Task?>(
      context,
      slideRoute(AddTaskScreen(task: task)),
    );
    if (result == null || !mounted) return;
    final all = await TaskStorage.loadTasks();
    final i = all.indexWhere((t) => t.id == result.id);
    if (i >= 0) {
      all[i] = result;
      await TaskStorage.saveTasks(all);
    }
    if (!mounted) return;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final body = _done.isEmpty
        ? const EmptyState(type: EmptyStateType.noCompleted)
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _done.length,
            itemBuilder: (ctx, i) {
              final t = _done[i];
              return TaskCard(
                task: t,
                onToggle: (v) => _toggle(t, v),
                onTap: () => _openEditor(t),
                onDelete: (task) => _delete(task),
              );
            },
          );
    if (!widget.showAppBar) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Tugas Selesai')),
      body: body,
    );
  }
}
