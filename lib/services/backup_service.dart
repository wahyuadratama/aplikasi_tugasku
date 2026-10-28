import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/task.dart';
import 'task_storage.dart';

class BackupService {
  /// Export semua tugas ke file JSON di Downloads folder.
  /// Return path file jika berhasil, null jika gagal.
  static Future<String?> exportTasks() async {
    try {
      final tasks = await TaskStorage.loadTasks();
      final json = jsonEncode(tasks.map((t) => t.toJson()).toList());

      // Coba simpan ke Downloads folder
      final downloadsDir = await _getDownloadsDirectory();
      if (downloadsDir == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'tugasku_backup_$timestamp.json';
      final file = File('${downloadsDir.path}/$fileName');

      await file.writeAsString(json);
      debugPrint('TugasKu: backup berhasil: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('TugasKu: gagal backup: $e');
      return null;
    }
  }

  /// Import tugas dari file JSON.
  /// Return jumlah tugas yang diimport, atau -1 jika gagal.
  static Future<int> importTasksFromPath(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final decoded = jsonDecode(content);

      if (decoded is! List) {
        throw const FormatException('File bukan list tugas');
      }

      final tasks = <Task>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        try {
          final task = Task.fromJson(Map<String, dynamic>.from(item));
          if (task.title.isEmpty) continue;
          tasks.add(task);
        } catch (e) {
          debugPrint('TugasKu: entri dilewati saat import: $e');
        }
      }

      // Merge dengan tugas yang ada (jangan overwrite)
      final existing = await TaskStorage.loadTasks();
      final merged = <Task>[];
      final existingIds = {for (final t in existing) t.id};

      // Tambah tugas yang sudah ada
      merged.addAll(existing);

      // Tambah tugas baru dari import (skip yang sudah ada)
      for (final t in tasks) {
        if (!existingIds.contains(t.id)) {
          merged.add(t);
        }
      }

      await TaskStorage.saveTasks(merged);
      debugPrint('TugasKu: import berhasil: ${tasks.length} tugas baru');
      return tasks.length;
    } catch (e) {
      debugPrint('TugasKu: gagal import: $e');
      return -1;
    }
  }

  /// Get Downloads directory. Fallback ke app documents jika tidak ada.
  static Future<Directory?> _getDownloadsDirectory() async {
    try {
      // Android: /storage/emulated/0/Download
      // iOS: Documents folder (tidak ada Downloads)
      if (Platform.isAndroid) {
        final dir = Directory('/storage/emulated/0/Download');
        if (await dir.exists()) return dir;
      }

      // Fallback: app documents directory
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      debugPrint('TugasKu: gagal get downloads dir: $e');
      return null;
    }
  }

  /// Get list backup files dari Downloads folder.
  static Future<List<File>> getBackupFiles() async {
    try {
      final dir = await _getDownloadsDirectory();
      if (dir == null) return [];

      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('tugasku_backup_'))
          .toList();

      // Sort by modified time (terbaru dulu)
      files.sort((a, b) =>
          b.statSync().modified.compareTo(a.statSync().modified));
      return files;
    } catch (e) {
      debugPrint('TugasKu: gagal list backup files: $e');
      return [];
    }
  }
}
