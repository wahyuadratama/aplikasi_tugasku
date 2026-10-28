import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final EmptyStateType type;

  const EmptyState({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(painter: _EmptyPainter(type: type, color: color)),
            ),
            const SizedBox(height: 24),
            Text(
              type.title,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              type.subtitle,
              style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

enum EmptyStateType {
  noTasks(
    title: 'Belum ada tugas',
    subtitle: 'Tambah tugas baru lewat tombol + di bawah',
  ),
  noCompleted(
    title: 'Belum ada yang selesai',
    subtitle: 'Selesaikan tugasmu dan centang di Beranda',
  ),
  noFiltered(
    title: 'Tidak ada tugas di kategori ini',
    subtitle: 'Coba pilih kategori lain atau tambah tugas baru',
  );

  const EmptyStateType({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}

class _EmptyPainter extends CustomPainter {
  final EmptyStateType type;
  final Color color;

  const _EmptyPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final bgPaint = Paint()..color = color.withValues(alpha: 0.08);
    final mainPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final accentPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Lingkaran background
    canvas.drawCircle(Offset(cx, cy), size.width * 0.42, bgPaint);

    if (type == EmptyStateType.noCompleted) {
      _drawCompleted(canvas, cx, cy, size, mainPaint, accentPaint, linePaint);
    } else {
      _drawClipboard(canvas, cx, cy, size, mainPaint, accentPaint, linePaint);
    }
  }

  void _drawClipboard(Canvas canvas, double cx, double cy, Size size,
      Paint mainPaint, Paint accentPaint, Paint linePaint) {
    final w = size.width * 0.45;
    final h = size.height * 0.55;
    final left = cx - w / 2;
    final top = cy - h / 2;

    // Badan clipboard
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, w, h),
      const Radius.circular(12),
    );
    canvas.drawRRect(body, mainPaint);

    // Klip atas
    final clipW = w * 0.4;
    final clipH = h * 0.1;
    final clipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - clipW / 2, top - clipH / 2, clipW, clipH),
      const Radius.circular(4),
    );
    canvas.drawRRect(clipRect, accentPaint);

    // Garis-garis tugas
    final lineLeft = left + w * 0.15;
    final lineRight = left + w * 0.85;
    final gaps = [0.28, 0.45, 0.62];
    for (final g in gaps) {
      final y = top + h * g;
      canvas.drawLine(Offset(lineLeft, y), Offset(lineRight, y), linePaint);
    }

    // Tanda + di tengah bawah
    if (type == EmptyStateType.noTasks) {
      final plusPaint = Paint()
        ..color = accentPaint.color
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final py = top + h * 0.8;
      canvas.drawLine(Offset(cx - 10, py), Offset(cx + 10, py), plusPaint);
      canvas.drawLine(Offset(cx, py - 10), Offset(cx, py + 10), plusPaint);
    }
  }

  void _drawCompleted(Canvas canvas, double cx, double cy, Size size,
      Paint mainPaint, Paint accentPaint, Paint linePaint) {
    // Lingkaran besar
    canvas.drawCircle(Offset(cx, cy), size.width * 0.28, mainPaint);

    // Centang
    final checkPaint = Paint()
      ..color = accentPaint.color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(cx - size.width * 0.13, cy)
      ..lineTo(cx - size.width * 0.02, cy + size.height * 0.1)
      ..lineTo(cx + size.width * 0.14, cy - size.height * 0.1);
    canvas.drawPath(path, checkPaint);

    // Bintang-bintang kecil dekoratif
    final starPaint = Paint()
      ..color = accentPaint.color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    for (final pos in [
      Offset(cx - size.width * 0.32, cy - size.height * 0.25),
      Offset(cx + size.width * 0.33, cy - size.height * 0.2),
      Offset(cx + size.width * 0.28, cy + size.height * 0.28),
    ]) {
      canvas.drawCircle(pos, 5, starPaint);
    }
  }

  @override
  bool shouldRepaint(_EmptyPainter old) =>
      old.type != type || old.color != color;
}
