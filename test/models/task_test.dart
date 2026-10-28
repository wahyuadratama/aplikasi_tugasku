import 'package:flutter_test/flutter_test.dart';
import 'package:tugasku/models/task.dart';

void main() {
  group('Task.fromJson', () {
    test('baca field lengkap dengan benar', () {
      final t = Task.fromJson({
        'id': '1',
        'title': 'Kerjakan laporan',
        'description': 'Bab 1-3',
        'deadline': '2026-10-12T00:00:00.000',
        'priority': 'high',
        'category': 'Kuliah',
        'isDone': true,
      });

      expect(t.id, '1');
      expect(t.title, 'Kerjakan laporan');
      expect(t.description, 'Bab 1-3');
      expect(t.deadline, DateTime(2026, 10, 12));
      expect(t.priority, TaskPriority.high);
      expect(t.category, 'Kuliah');
      expect(t.isDone, isTrue);
    });

    test('field hilang -> nilai default, tidak melempar error', () {
      final t = Task.fromJson({'title': 'Tanpa id'});

      expect(t.id, isNotEmpty);
      expect(t.title, 'Tanpa id');
      expect(t.description, '');
      expect(t.deadline, isNull);
      expect(t.priority, TaskPriority.medium);
      expect(t.category, 'Umum');
      expect(t.isDone, isFalse);
    });

    test('json sama sekali bukan map -> tidak crash', () {
      final t = Task.fromJson(<String, dynamic>{});
      expect(t.title, '');
      expect(t.priority, TaskPriority.medium);
    });

    test('prioritas tak dikenal -> medium (bukan crash)', () {
      expect(Task.fromJson({'priority': 'hight'}).priority,
          TaskPriority.medium);
      expect(Task.fromJson({'priority': 'HIGH'}).priority, TaskPriority.high);
      expect(Task.fromJson({'priority': 42}).priority, TaskPriority.medium);
    });

    test('isDoneAccept varied -> bool', () {
      expect(Task.fromJson({'isDone': true}).isDone, isTrue);
      expect(Task.fromJson({'isDone': 'true'}).isDone, isTrue);
      expect(Task.fromJson({'isDone': 1}).isDone, isTrue);
      expect(Task.fromJson({'isDone': 'nope'}).isDone, isFalse);
      expect(Task.fromJson({'isDone': null}).isDone, isFalse);
    });
  });

  group('Task.parseDeadline', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    test('null / kosong -> null', () {
      expect(Task.parseDeadline(null), isNull);
      expect(Task.parseDeadline(''), isNull);
      expect(Task.parseDeadline('   '), isNull);
    });

    test('format lama "Hari ini" -> hari ini', () {
      expect(Task.parseDeadline('Hari ini'), today);
      expect(Task.parseDeadline('hari ini'), today);
    });

    test('format lama "Besok" -> besok', () {
      expect(Task.parseDeadline('Besok'), today.add(const Duration(days: 1)));
    });

    test('format lama "Selesai" -> null', () {
      expect(Task.parseDeadline('Selesai'), isNull);
    });

    test('format lama "12/10/2026" -> DateTime', () {
      expect(Task.parseDeadline('12/10/2026'), DateTime(2026, 10, 12));
    });

    test('format lama 2 digit tahun -> abad 21', () {
      expect(Task.parseDeadline('12/10/26'), DateTime(2026, 10, 12));
    });

    test('tanggal tak valid -> null', () {
      expect(Task.parseDeadline('99/99/2026'), isNull);
      expect(Task.parseDeadline('bukan tanggal'), isNull);
    });

    test('ISO-8601 -> DateTime tanpa jam', () {
      expect(Task.parseDeadline('2026-10-12T08:30:00.000'),
          DateTime(2026, 10, 12));
    });

    test('DateTime langsung -> dinormalkan tanpa jam', () {
      expect(Task.parseDeadline(DateTime(2026, 10, 12, 15, 30)),
          DateTime(2026, 10, 12));
    });
  });

  group('Task misc', () {
    test('toJson -> fromJson conserving nilai', () {
      final t = Task(
        id: '9',
        title: 'Uji',
        description: 'desc',
        deadline: DateTime(2026, 12, 1),
        priority: TaskPriority.low,
        category: 'Belanja',
        isDone: false,
      );

      final back = Task.fromJson(t.toJson());
      expect(back.id, t.id);
      expect(back.title, t.title);
      expect(back.deadline, t.deadline);
      expect(back.priority, t.priority);
      expect(back.category, t.category);
      expect(back.isDone, t.isDone);
    });

    test('copyWith tanpa deadline -> deadline tetap', () {
      final t = Task(id: '1', title: 'A', deadline: DateTime(2026, 10, 12));
      expect(t.copyWith(title: 'B').deadline, DateTime(2026, 10, 12));
    });

    test('copyWith deadline null -> deadline dihapus', () {
      final t = Task(id: '1', title: 'A', deadline: DateTime(2026, 10, 12));
      expect(t.copyWith(deadline: null).deadline, isNull);
    });

    test('categoryKey case-insensitive', () {
      expect(const Task(id: '1', title: 'A', category: 'Kuliah').categoryKey,
          'kuliah');
      expect(const Task(id: '1', title: 'A', category: '  KULIAH  ').categoryKey,
          'kuliah');
    });

    test('normalizeCategory -> "Umum" bila kosong', () {
      expect(Task.normalizeCategory(null), 'Umum');
      expect(Task.normalizeCategory('  '), 'Umum');
      expect(Task.normalizeCategory(' Kuliah '), 'Kuliah');
    });

    test('isOverdue hanya untuk tugas belum selesai', () {
      final now = DateTime.now();
      final lalu = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 2));

      expect(Task(id: '1', title: 'A', deadline: lalu).isOverdue, isTrue);
      expect(Task(id: '1', title: 'A', deadline: lalu, isDone: true).isOverdue,
          isFalse);
      expect(const Task(id: '1', title: 'A').isOverdue, isFalse);
    });

    test('deadlineLabel mengikuti status tugas', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(Task(id: '1', title: 'A', deadline: today).deadlineLabel,
          'Hari ini');
      expect(Task(id: '1', title: 'A', deadline: today, isDone: true)
          .deadlineLabel, 'Selesai');
    });
  });

  group('TaskPriority', () {
    test('fromName fallback ke medium', () {
      expect(TaskPriority.fromName('high'), TaskPriority.high);
      expect(TaskPriority.fromName('low'), TaskPriority.low);
      expect(TaskPriority.fromName('medium'), TaskPriority.medium);
      expect(TaskPriority.fromName('gibilan'), TaskPriority.medium);
      expect(TaskPriority.fromName(null), TaskPriority.medium);
    });

    test('label siap tampil', () {
      expect(TaskPriority.high.label, 'Tinggi');
      expect(TaskPriority.medium.label, 'Sedang');
      expect(TaskPriority.low.label, 'Rendah');
    });
  });
}
