import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugasku/screens/home_screen.dart';
import 'package:tugasku/widgets/task_card.dart';

const String _key = 'tugasku_tasks';

List<Map<String, dynamic>> _tasks({
  int aktif = 2,
  int selesai = 0,
}) {
  final list = <Map<String, dynamic>>[];
  for (var i = 0; i < aktif; i++) {
    list.add({
      'id': 'a$i',
      'title': 'Tugas Aktif $i',
      'description': '',
      'deadline': null,
      'priority': 'high',
      'category': i == 0 ? 'Kuliah' : 'Umum',
      'isDone': false,
    });
  }
  for (var i = 0; i < selesai; i++) {
    list.add({
      'id': 'b$i',
      'title': 'Tugas Selesai $i',
      'description': '',
      'deadline': null,
      'priority': 'low',
      'category': 'Umum',
      'isDone': true,
    });
  }
  return list;
}

void main() {
  testWidgets('menampilkan tugas aktif dari storage', (tester) async {
    SharedPreferences.setMockInitialValues({_key: jsonEncode(_tasks())});

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Tugas Aktif 0'), findsOneWidget);
    expect(find.text('Tugas Aktif 1'), findsOneWidget);
    expect(find.text('Daftar tugasmu'), findsOneWidget);
  });

  testWidgets('filter kategori menyaring daftar', (tester) async {
    SharedPreferences.setMockInitialValues({_key: jsonEncode(_tasks())});

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Kuliah'));
    await tester.pumpAndSettle();

    expect(find.text('Tugas Aktif 0'), findsOneWidget);
    expect(find.text('Tugas Aktif 1'), findsNothing);
  });

  testWidgets('filter otomatis balik ke "Semua" kalau kategorinya hilang',
      (tester) async {
    SharedPreferences.setMockInitialValues({_key: jsonEncode(_tasks())});

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Kuliah'));
    await tester.pumpAndSettle();
    expect(find.text('Tugas Aktif 0'), findsOneWidget);

    // Hapus satu-satunya tugas di kategori yang difilter.
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // Filter harus kembali ke "Semua", bukan menampilkan layar kosong.
    expect(find.text('Tugas Aktif 1'), findsOneWidget);
    expect(find.text('Belum ada tugas. Tambah lewat tombol + ya!'), findsNothing);
  });

  testWidgets('mencentang tugas memindahkannya ke daftar selesai',
      (tester) async {
    SharedPreferences.setMockInitialValues({_key: jsonEncode(_tasks())});

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    final sem = find.bySemanticsLabel('toggle task');
    if (sem.evaluate().isNotEmpty) {
      await tester.tap(sem.first);
    } else {
      final card = find.byType(TaskCard).first;
      await tester.tap(find.descendant(of: card, matching: find.byType(InkWell)).first);
    }
    await tester.pumpAndSettle();

    expect(find.text('Tugas Aktif 0'), findsNothing);
  });

  testWidgets('layar selesai menampilkan tugas yang sudah dicentang',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      _key: jsonEncode(_tasks(aktif: 1, selesai: 1)),
    });

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    // Tap menu overflow (more_vert icon)
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Tap "Tugas Selesai" dari menu
    await tester.tap(find.text('Tugas Selesai'));
    await tester.pumpAndSettle();

    expect(find.text('Tugas Selesai'), findsOneWidget);
    expect(find.text('Tugas Selesai 0'), findsOneWidget);
  });

  testWidgets('kategori dengan beda huruf besar tidak dipecah jadi dua chip',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      _key: jsonEncode([
        {'id': '1', 'title': 'A', 'category': 'Kuliah', 'isDone': false},
        {'id': '2', 'title': 'B', 'category': 'kuliah', 'isDone': false},
      ]),
    });

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ChoiceChip, 'Kuliah'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'kuliah'), findsNothing);
  });

  testWidgets('kategori berbeda tetap dipisah jadi chip terpisah',
      (tester) async {
    // Kategori berbeda (bukan beda kapitalisasi) tetap dipisah.
    SharedPreferences.setMockInitialValues({
      _key: jsonEncode([
        {'id': '1', 'title': 'A', 'category': 'Kuliah', 'isDone': false},
        {'id': '2', 'title': 'B', 'category': 'Belanja', 'isDone': false},
      ]),
    });

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ChoiceChip, 'Kuliah'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Belanja'), findsOneWidget);
  });
}
