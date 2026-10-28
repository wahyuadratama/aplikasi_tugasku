import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/task.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  /// Minta izin notifikasi (Android 13+).
  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Jadwalkan reminder untuk [task].
  /// - H-1 pukul 08.00 kalau deadline besok atau lebih
  /// - Hari-H pukul 08.00 kalau deadline hari ini
  /// Tidak menjadwalkan kalau deadline sudah lewat atau null.
  static Future<void> scheduleReminder(Task task) async {
    if (task.deadline == null) return;
    await cancelReminder(task.id);

    final now = DateTime.now();
    final deadline = task.deadline!;

    // Tentukan waktu notifikasi: H-1 atau hari-H pukul 08.00
    final dayBefore = DateTime(
        deadline.year, deadline.month, deadline.day - 1, 8, 0);
    final dayOf = DateTime(deadline.year, deadline.month, deadline.day, 8, 0);

    DateTime? scheduleAt;
    String body;

    if (dayBefore.isAfter(now)) {
      scheduleAt = dayBefore;
      body = 'Deadline besok: ${task.deadlineLabel}';
    } else if (dayOf.isAfter(now)) {
      scheduleAt = dayOf;
      body = 'Deadline hari ini!';
    } else {
      return; // deadline sudah lewat
    }

    final tzSchedule = tz.TZDateTime.from(scheduleAt, tz.local);

    await _plugin.zonedSchedule(
      _idFromTaskId(task.id),
      task.title,
      body,
      tzSchedule,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'tugasku_reminder',
          'Reminder Tugas',
          channelDescription: 'Pengingat deadline tugas',
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF6C63FF),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Batalkan reminder untuk task dengan [taskId].
  static Future<void> cancelReminder(String taskId) async {
    try {
      await _plugin.cancel(_idFromTaskId(taskId));
    } catch (_) {
      // Ignore errors di test environment atau saat plugin belum init
    }
  }

  /// Batalkan semua reminder.
  static Future<void> cancelAll() => _plugin.cancelAll();

  /// Konversi task id string ke int untuk notification id.
  static int _idFromTaskId(String taskId) =>
      taskId.hashCode.abs() % 100000;
}
