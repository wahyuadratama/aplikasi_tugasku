import 'package:flutter_test/flutter_test.dart';
import 'package:tugasku/utils/date_label.dart';

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  group('formatDeadline', () {
    test('tugas selesai -> "Selesai"', () {
      expect(formatDeadline(DateTime(2026, 10, 12), isDone: true), 'Selesai');
      expect(formatDeadline(null, isDone: true), 'Selesai');
    });

    test('tanpa deadline -> "Tanpa deadline"', () {
      expect(formatDeadline(null), 'Tanpa deadline');
    });

    test('hari ini / besok / kemarin', () {
      expect(formatDeadline(today), 'Hari ini');
      expect(formatDeadline(today.add(const Duration(days: 1))), 'Besok');
      expect(formatDeadline(today.subtract(const Duration(days: 1))), 'Kemarin');
    });

    test('sudah lewat -> tanggal + penanda terlambat', () {
      final lalu = today.subtract(const Duration(days: 3));
      expect(formatDeadline(lalu), '${formatDate(lalu)} (terlambat)');
    });

    test('tahun ini -> "<hari> <bulan>"', () {
      final d = DateTime(now.year, 12, 31);
      if (d.isBefore(today)) {
        expect(formatDeadline(d), 'Hari ini');
      } else {
        expect(formatDeadline(d), '31 Des');
      }
    });

    test('tahun lain -> dd/MM/yyyy', () {
      final d = DateTime(now.year + 1, 3, 12);
      expect(formatDeadline(d), '12/3/${now.year + 1}');
    });
  });

  group('formatDate', () {
    test('format eksplisit', () {
      expect(formatDate(DateTime(2026, 10, 5)), '5/10/2026');
    });
  });

  group('isBeforeToday', () {
    test('dulu -> true, hari ini -> false, besok -> false', () {
      expect(isBeforeToday(today.subtract(const Duration(days: 1))), isTrue);
      expect(isBeforeToday(today), isFalse);
      expect(isBeforeToday(today.add(const Duration(days: 1))), isFalse);
    });
  });
}
