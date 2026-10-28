// Utilitas format tanggal untuk ditampilkan di UI.

const List<String> _bulanSingkat = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Tanggal hari ini tanpa jam.
DateTime todayDate() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// True kalau [d] jatuh sebelum hari ini.
bool isBeforeToday(DateTime d) {
  final t = todayDate();
  return DateTime(d.year, d.month, d.day).isBefore(t);
}

/// Format tanggal eksplisit, contoh: "12/10/2026".
String formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

/// Label deadline yang ramah dibaca manusia.
/// - Tugas selesai -> "Selesai"
/// - Tanpa tanggal -> "Tanpa deadline"
/// - Hari ini / besok / kemarin
/// - Sudah lewat -> "12/10/2026 (terlambat)"
/// - Tahun ini -> "12 Okt", tahun lain -> "12/10/2026"
String formatDeadline(DateTime? deadline, {bool isDone = false}) {
  if (isDone) return 'Selesai';
  if (deadline == null) return 'Tanpa deadline';
  final d = DateTime(deadline.year, deadline.month, deadline.day);
  final diff = d.difference(todayDate()).inDays;
  if (diff == 0) return 'Hari ini';
  if (diff == 1) return 'Besok';
  if (diff == -1) return 'Kemarin';
  if (diff < 0) return '${formatDate(d)} (terlambat)';
  if (d.year == todayDate().year) return '${d.day} ${_bulanSingkat[d.month - 1]}';
  return formatDate(d);
}
