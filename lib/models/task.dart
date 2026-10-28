// Model satu tugas di aplikasi TugasKu.
//
// Deadline disimpan sebagai DateTime (bukan teks) supaya bisa diurutkan dan
// dicek apakah sudah lewat. Data lama (deadline berupa teks seperti "Hari ini")
// tetap bisa dibaca — lihat Task.parseDeadline.
library;

import '../utils/date_label.dart';
import 'sub_task.dart';

/// Tipe pengulangan tugas.
enum RecurrenceType {
  none('Tidak berulang'),
  daily('Setiap hari'),
  weekly('Setiap minggu'),
  monthly('Setiap bulan'),
  yearly('Setiap tahun');

  const RecurrenceType(this.label);
  final String label;

  static RecurrenceType fromName(Object? name) {
    if (name is! String) return RecurrenceType.none;
    return RecurrenceType.values.firstWhere((r) => r.name == name,
        orElse: () => RecurrenceType.none);
  }
}

/// Prioritas tugas. Dipakai enum supaya tidak ada typo diam-diam.
enum TaskPriority {
  high('Tinggi'),
  medium('Sedang'),
  low('Rendah');

  const TaskPriority(this.label);

  /// Label siap tampil, contoh: "Tinggi".
  final String label;

  /// Ambil prioritas dari nama enum. Nilai tak dikenal -> medium.
  static TaskPriority fromName(Object? name) {
    if (name is! String) return TaskPriority.medium;
    final v = name.trim().toLowerCase();
    for (final p in TaskPriority.values) {
      if (p.name == v) return p;
    }
    return TaskPriority.medium;
  }
}

/// Satu tugas di aplikasi TugasKu.
class Task {
  final String id;
  final String title;
  final String description;

  /// Tanggal tenggat. Null = tanpa deadline.
  final DateTime? deadline;

  final TaskPriority priority;
  final String category;
  final bool isDone;
  final bool reminder;
  final List<SubTask> subTasks;
  final RecurrenceType recurrence;
  final DateTime? recurrenceEndDate;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.deadline,
    this.priority = TaskPriority.medium,
    this.category = 'Umum',
    this.isDone = false,
    this.reminder = false,
    this.subTasks = const [],
    this.recurrence = RecurrenceType.none,
    this.recurrenceEndDate,
  });

  /// Kunci perbandingan kategori (case-insensitive) supaya "Kuliah" dan
  /// "kuliah" tidak jadi dua kategori berbeda.
  String get categoryKey => category.trim().toLowerCase();

  /// Deadline sudah lewat? (tugas selesai tidak dianggap terlambat)
  bool get isOverdue =>
      !isDone && deadline != null && isBeforeToday(deadline!);

  /// Progress sub-tugas: berapa yang sudah selesai.
  int get subTasksDone => subTasks.where((st) => st.isDone).length;

  /// Total sub-tugas.
  int get subTasksTotal => subTasks.length;

  /// Persentase selesai (0–100).
  int get subTasksProgress =>
      subTasksTotal == 0 ? 0 : (subTasksDone * 100 / subTasksTotal).round();

  /// Label deadline siap tampil, contoh: "Hari ini", "Besok", "12/10/2026".
  String get deadlineLabel => formatDeadline(deadline, isDone: isDone);

  Task copyWith({
    String? id,
    String? title,
    String? description,
    Object? deadline = _unset,
    TaskPriority? priority,
    String? category,
    bool? isDone,
    bool? reminder,
    List<SubTask>? subTasks,
    RecurrenceType? recurrence,
    Object? recurrenceEndDate = _unset,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: identical(deadline, _unset) ? this.deadline : deadline as DateTime?,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
      reminder: reminder ?? this.reminder,
      subTasks: subTasks ?? this.subTasks,
      recurrence: recurrence ?? this.recurrence,
      recurrenceEndDate: identical(recurrenceEndDate, _unset)
          ? this.recurrenceEndDate
          : recurrenceEndDate as DateTime?,
    );
  }

  /// Untuk simpan ke SharedPreferences (JSON).
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'deadline': deadline?.toIso8601String(),
        'priority': priority.name,
        'category': category,
        'isDone': isDone,
        'reminder': reminder,
        'subTasks': subTasks.map((st) => st.toJson()).toList(),
        'recurrence': recurrence.name,
        'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawId = _asString(json['id']);
    final title = _asString(json['title']);
    return Task(
      id: rawId.isEmpty ? _generatedId() : rawId,
      title: title,
      description: _asString(json['description']),
      deadline: parseDeadline(json['deadline']),
      priority: TaskPriority.fromName(json['priority']),
      category: normalizeCategory(json['category']),
      isDone: switch (json['isDone']) {
        final bool b => b,
        final String s => s.toLowerCase() == 'true',
        final int i => i != 0,
        _ => false,
      },
      reminder: switch (json['reminder']) {
        final bool b => b,
        final int i => i != 0,
        _ => false,
      },
      subTasks: switch (json['subTasks']) {
        final List list => list
            .whereType<Map<String, dynamic>>()
            .map(SubTask.fromJson)
            .toList(),
        _ => const [],
      },
      recurrence: RecurrenceType.fromName(json['recurrence']),
      recurrenceEndDate: parseDeadline(json['recurrenceEndDate']),
    );
  }

  /// Cast aman ke String: nilai bukan String dianggap string kosong.
  static String _asString(Object? v) => v is String ? v.trim() : '';

  /// Parse deadline dari berbagai format:
  /// - ISO-8601 (format baru): "2026-10-12T00:00:00.000"
  /// - "12/10/2026" (format lama)
  /// - "Hari ini" / "Besok" / "Kemarin" (format lama)
  /// - "Selesai" -> null (tugas selesai tak punya tanggal)
  static DateTime? parseDeadline(Object? raw) {
    if (raw == null) return null;
    if (raw is DateTime) {
      return DateTime(raw.year, raw.month, raw.day);
    }
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (s.toLowerCase()) {
      case 'hari ini':
        return today;
      case 'besok':
        return today.add(const Duration(days: 1));
      case 'kemarin':
        return today.subtract(const Duration(days: 1));
      case 'selesai':
        return null;
    }
    final m =
        RegExp(r'^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2,4})$').firstMatch(s);
    if (m != null) {
      final day = int.parse(m.group(1)!);
      final month = int.parse(m.group(2)!);
      var year = int.parse(m.group(3)!);
      if (year < 100) year += 2000;
      if (month < 1 || month > 12 || day < 1 || day > 31) return null;
      return DateTime(year, month, day);
    }
    final parsed = DateTime.tryParse(s);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  /// Bersihkan nama kategori. Kosong -> "Umum".
  static String normalizeCategory(Object? raw) {
    final s = _asString(raw);
    return s.isEmpty ? 'Umum' : s;
  }

  static String _generatedId() =>
      'task-${DateTime.now().microsecondsSinceEpoch}';
}

const _unset = Object();

/// Opsi urutan daftar tugas.
enum TaskSort {
  manual('Urutan manual'),
  deadline('Deadline terdekat'),
  priority('Prioritas tertinggi'),
  name('Nama A–Z');

  const TaskSort(this.label);
  final String label;

  static TaskSort fromName(Object? name) {
    if (name is! String) return TaskSort.manual;
    return TaskSort.values.firstWhere((s) => s.name == name,
        orElse: () => TaskSort.manual);
  }
}

/// Urutkan list tugas sesuai [sort]. List asli tidak diubah.
List<Task> sortTasks(List<Task> tasks, TaskSort sort) {
  final list = [...tasks];
  switch (sort) {
    case TaskSort.manual:
      break;
    case TaskSort.deadline:
      list.sort((a, b) {
        if (a.deadline == null && b.deadline == null) return 0;
        if (a.deadline == null) return 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      });
    case TaskSort.priority:
      list.sort((a, b) => a.priority.index.compareTo(b.priority.index));
    case TaskSort.name:
      list.sort((a, b) => a.title.compareTo(b.title));
  }
  return list;
}
