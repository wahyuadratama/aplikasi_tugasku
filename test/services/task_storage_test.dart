import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugasku/models/task.dart';
import 'package:tugasku/services/task_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const key = 'tugasku_tasks';

  group('TaskStorage.loadTasks', () {
    test('prekosong -> mengembalikan data contoh', () async {
      SharedPreferences.setMockInitialValues({});

      final tasks = await TaskStorage.loadTasks();

      expect(tasks, isNotEmpty);
      expect(tasks.any((t) => t.title == 'Kerjakan laporan metopen'), isTrue);
    });

    test('data contoh ikut tersimpan (tidak muncul ulang tiap launch)',
        () async {
      SharedPreferences.setMockInitialValues({});

      await TaskStorage.loadTasks();
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getString(key), isNotNull);
      expect(prefs.getInt('tugasku_schema_version'), TaskStorage.schemaVersion);
    });

    test('data JSON lama (deadline teks) tetap terbaca', () async {
      SharedPreferences.setMockInitialValues({
        key: jsonEncode([
          {
            'id': '1',
            'title': 'Tugas lama',
            'description': '',
            'deadline': 'Hari ini',
            'priority': 'high',
            'category': 'Kuliah',
            'isDone': false,
          }
        ]),
      });

      final tasks = await TaskStorage.loadTasks();

      expect(tasks, hasLength(1));
      expect(tasks.first.deadline, isNotNull);
      expect(tasks.first.priority, TaskPriority.high);
    });

    test('JSON korup -> tidak crash, data dicadangkan, list kosong', () async {
      SharedPreferences.setMockInitialValues({key: '{ini bukan json'});

      final tasks = await TaskStorage.loadTasks();

      expect(tasks, isEmpty);
      expect(await TaskStorage.hasCorruptBackup(), isTrue);
    });

    test('isi bukan list -> tidak crash', () async {
      SharedPreferences.setMockInitialValues({key: '{"a":1}'});

      final tasks = await TaskStorage.loadTasks();

      expect(tasks, isEmpty);
    });

    test('entri rusak dilewati, entri valid tetap dipakai', () async {
      SharedPreferences.setMockInitialValues({
        key: jsonEncode([
          'bukan map',
          {'id': '1', 'title': 'Masih hidup', 'isDone': false},
          {'id': '2', 'title': '', 'isDone': false},
        ]),
      });

      final tasks = await TaskStorage.loadTasks();

      expect(tasks, hasLength(1));
      expect(tasks.first.title, 'Masih hidup');
    });

    test('field rusak tidak membuat seluruh load gagal', () async {
      SharedPreferences.setMockInitialValues({
        key: jsonEncode([
          {'id': 123, 'title': 'Judul dipakai', 'priority': 'high'},
        ]),
      });

      final tasks = await TaskStorage.loadTasks();

      expect(tasks.first.title, 'Judul dipakai');
      expect(tasks.first.priority, TaskPriority.high);
    });
  });

  group('TaskStorage.saveTasks', () {
    test('simpan lalu baca kembali -> data sama', () async {
      SharedPreferences.setMockInitialValues({});

      final tasks = [
        const Task(
          id: '1',
          title: 'Tugas A',
          description: 'desc',
          deadline: null,
          priority: TaskPriority.high,
          category: 'Kuliah',
        ),
        Task(
          id: '2',
          title: 'Tugas B',
          deadline: DateTime(2026, 10, 12),
          priority: TaskPriority.low,
          category: 'Belanja',
          isDone: true,
        ),
      ];

      await TaskStorage.saveTasks(tasks);
      final loaded = await TaskStorage.loadTasks();

      expect(loaded, hasLength(2));
      expect(loaded[0].title, 'Tugas A');
      expect(loaded[0].priority, TaskPriority.high);
      expect(loaded[1].deadline, DateTime(2026, 10, 12));
      expect(loaded[1].isDone, isTrue);
    });

    test('daftar kosong tersimpan sebagai [] (bukan null)', () async {
      SharedPreferences.setMockInitialValues({});

      await TaskStorage.saveTasks(const []);
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getString(key), '[]');
      expect(await TaskStorage.loadTasks(), isEmpty);
    });
  });
}
