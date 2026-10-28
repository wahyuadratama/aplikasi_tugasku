// Penyimpanan tugas memakai SharedPreferences (disimpan sebagai JSON).
// Sederhana dan cukup untuk tugas kuliah; data tetap ada walau aplikasi ditutup.
//
// Semua baca/tulis dibungkus try-catch: data yang korup tidak boleh bikin
// aplikasi crash atau kehilangan data — data mentah dicadangkan di key terpisah.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskStorage {
  static const _key = 'tugasku_tasks';
  static const _versionKey = 'tugasku_schema_version';
  static const _corruptKey = 'tugasku_tasks_corrupt_backup';
  static const _themeModeKey = 'tugasku_theme_mode';
  static const _sortKey = 'tugasku_sort';

  /// Versi skema data. Bumped saat format penyimpanan berubah.
  static const int schemaVersion = 2;

  /// Ambil semua tugas. Kalau belum pernah simpan, isi contoh sesuai desain Figma.
  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) {
      final seed = _seedTasks();
      await saveTasks(seed);
      return seed;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const FormatException('Isi penyimpanan bukan list');
      }
      final tasks = <Task>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        try {
          final task = Task.fromJson(Map<String, dynamic>.from(item));
          if (task.title.isEmpty) continue; // entri tanpa judul -> skip
          tasks.add(task);
        } catch (e) {
          debugPrint('TugasKu: entri tugas dilewati: $e');
        }
      }
      return tasks;
    } catch (e) {
      // Data korup: jangan hapus, simpan cadangan lalu kembalikan list kosong.
      debugPrint('TugasKu: penyimpanan korup, data dicadangkan: $e');
      try {
        await prefs.setString(_corruptKey, raw);
      } catch (_) {
        // Best effort — kegagalan cadangan tidak boleh menggagalkan load.
      }
      return const <Task>[];
    }
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
      await prefs.setString(_key, raw);
      await prefs.setInt(_versionKey, schemaVersion);
    } catch (e) {
      debugPrint('TugasKu: gagal menyimpan tugas: $e');
    }
  }

  static Future<void> saveSort(TaskSort sort) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortKey, sort.name);
  }

  static Future<TaskSort> loadSort() async {
    final prefs = await SharedPreferences.getInstance();
    return TaskSort.fromName(prefs.getString(_sortKey));
  }

  /// Simpan preferensi theme mode.
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  /// Ambil preferensi theme mode. Default: system.
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  /// True kalau ada data korup yang tertinggal di cadangan.
  static Future<bool> hasCorruptBackup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_corruptKey) != null;
  }

  /// Get SharedPreferences instance untuk akses langsung.
  static Future<SharedPreferences> getPreferences() async {
    return SharedPreferences.getInstance();
  }

  /// Data contoh persis seperti di desain Figma yang disetujui.
  static List<Task> _seedTasks() {
    final today = DateTime.now();
    final day0 = DateTime(today.year, today.month, today.day);
    // Jumat terdekat (0 = hari ini kalau hari ini Jumat).
    final toFriday = (DateTime.friday - day0.weekday + 7) % 7;
    return [
      Task(
        id: '1',
        title: 'Kerjakan laporan metopen',
        deadline: day0,
        priority: TaskPriority.high,
        category: 'Kuliah',
      ),
      Task(
        id: '2',
        title: 'Beli bahan dapur',
        deadline: day0.add(const Duration(days: 1)),
        priority: TaskPriority.low,
        category: 'Belanja',
      ),
      Task(
        id: '3',
        title: 'Revisi desain Figma',
        deadline: day0.add(Duration(days: toFriday)),
        priority: TaskPriority.medium,
        category: 'Kuliah',
      ),
      Task(
        id: '4',
        title: 'Cuci motor',
        priority: TaskPriority.low,
        category: 'Umum',
        isDone: true,
      ),
      Task(
        id: '5',
        title: 'Bayar kos',
        priority: TaskPriority.medium,
        category: 'Umum',
        isDone: true,
      ),
    ];
  }
}
