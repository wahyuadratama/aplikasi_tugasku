import 'package:flutter/foundation.dart';

/// Satu item checklist di dalam tugas utama.
@immutable
class SubTask {
  final String id;
  final String title;
  final bool isDone;

  const SubTask({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isDone,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isDone': isDone,
      };

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      isDone: switch (json['isDone']) {
        final bool b => b,
        final String s => s.toLowerCase() == 'true',
        final int i => i != 0,
        _ => false,
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubTask &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          isDone == other.isDone;

  @override
  int get hashCode => Object.hash(id, title, isDone);
}
