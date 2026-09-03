import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_report.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Ball dinamikasi. Nuqtalar oz (odatda 12 tagacha), shuning uchun oddiy
/// siniq chiziq yetarli — grafik kutubxonasi qo'shilmaydi.
final class KatmChart extends StatelessWidget {
  const KatmChart({super.key, required this.points});

  final List<KatmDynamic> points;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return Text("Dinamika uchun ma'lumot yetarli emas", style: AppTheme.data.textTheme.bodySmall);
    }

    final int min = points.map((KatmDynamic e) => e.score).reduce((int a, int b) => a < b ? a : b);
    final int max = points.map((KatmDynamic e) => e.score).reduce((int a, int b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: ScreenSize.h120,
          width: double.infinity,
          child: CustomPaint(
            painter: _ChartPainter(
              scores: points.map((KatmDynamic e) => e.score).toList(),
              min: min,
              max: max,
              lineColor: AppTheme.colors.primary,
              fillColor: AppTheme.colors.primary.withValues(alpha: .12),
            ),
          ),
        ),

        Gap(ScreenSize.h6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(points.first.period, style: AppTheme.data.textTheme.bodySmall),
            Text("$min – $max", style: AppTheme.data.textTheme.bodySmall),
            Text(points.last.period, style: AppTheme.data.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

final class _ChartPainter extends CustomPainter {
  const _ChartPainter({
    required this.scores,
    required this.min,
    required this.max,
    required this.lineColor,
    required this.fillColor,
  });

  final List<int> scores;
  final int min;
  final int max;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double step = size.width / (scores.length - 1);
    // Barcha qiymat teng bo'lsa chiziq o'rtadan o'tadi.
    final int span = max - min == 0 ? 1 : max - min;

    final Path line = Path();
    for (int i = 0; i < scores.length; i++) {
      final double x = step * i;
      final double y = size.height - ((scores[i] - min) / span) * size.height * .85 - size.height * .08;

      if (i == 0) {
        line.moveTo(x, y);
      } else {
        line.lineTo(x, y);
      }
    }

    final Path fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fill, Paint()..color = fillColor);
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = lineColor,
    );

    for (int i = 0; i < scores.length; i++) {
      final double x = step * i;
      final double y = size.height - ((scores[i] - min) / span) * size.height * .85 - size.height * .08;
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.scores != scores || old.min != min || old.max != max;
}
