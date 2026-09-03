import 'dart:math' as math;

import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_report.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Skoring balli shkalasi. Zonalar backenddan keladi, qat'iy yozilmaydi.
///
/// Nega `CustomPainter`: bitta yoy uchun grafik kutubxonasi qo'shish ortiqcha.
final class KatmGauge extends StatelessWidget {
  const KatmGauge({super.key, required this.scoring});

  final KatmScoring scoring;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Shkala kelmasa yoy chizilmaydi — noto'g'ri o'rin ko'rsatgandan
        // ko'ra faqat ballni ko'rsatgan yaxshi.
        SizedBox(
          height: ScreenSize.h140,
          width: double.infinity,
          child: CustomPaint(
            painter: !scoring.hasScale
                ? null
                : _GaugePainter(
                    position: scoring.position,
                    bands: scoring.bands,
                    min: scoring.min,
                    max: scoring.max,
                    trackColor: AppTheme.colors.grey1,
                    needleColor: AppTheme.colors.blackSoft,
                  ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Gap(ScreenSize.h20),
                  Text(
                    "${scoring.grade}",
                    style: AppTheme.data.textTheme.displayLarge?.copyWith(
                      color: AppTheme.colors.blackSoft,
                      fontSize: ScreenSize.sp32,
                    ),
                  ),

                  if (scoring.className.isNotEmpty)
                    Text(
                      scoring.className,
                      style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.primary),
                    ),
                ],
              ),
            ),
          ),
        ),

        if (scoring.level.isNotEmpty)
          Text(scoring.level, textAlign: TextAlign.center, style: AppTheme.data.textTheme.bodyMedium),
      ],
    );
  }
}

final class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.position,
    required this.bands,
    required this.min,
    required this.max,
    required this.trackColor,
    required this.needleColor,
  });

  final double position;
  final List<KatmBand> bands;
  final int min;
  final int max;
  final Color trackColor;
  final Color needleColor;

  /// Yarim doira: chapdan o'ngga.
  static const double _start = math.pi;
  static const double _sweep = math.pi;

  /// Zona ranglari — eng pastdan eng yuqorigacha.
  static const List<Color> _bandColors = <Color>[
    Color(0xFFE53935),
    Color(0xFFFB8C00),
    Color(0xFFFDD835),
    Color(0xFF7CB342),
    Color(0xFF00BB31),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = size.height * .12;
    final Rect rect = Rect.fromLTWH(stroke, stroke, size.width - stroke * 2, (size.height - stroke) * 2);

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    canvas.drawArc(rect, _start, _sweep, false, track);

    if (max > min) {
      for (int i = 0; i < bands.length; i++) {
        final double from = ((bands[i].from - min) / (max - min)).clamp(0.0, 1.0);
        final double to = ((bands[i].to - min) / (max - min)).clamp(0.0, 1.0);
        if (to <= from) continue;

        final Paint paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = _bandColors[i % _bandColors.length];

        canvas.drawArc(rect, _start + _sweep * from, _sweep * (to - from), false, paint);
      }
    }

    // Ko'rsatkich yoyning ichida qoladi: to'liq radius bilan u chizmadan
    // chiqib ketardi.
    final Offset center = Offset(size.width / 2, size.height);
    final double angle = _start + _sweep * position;
    final double radius = rect.width / 2 - stroke;

    canvas.drawLine(
      center,
      center + Offset(math.cos(angle) * radius, math.sin(angle) * radius),
      Paint()
        ..strokeWidth = stroke * .28
        ..strokeCap = StrokeCap.round
        ..color = needleColor,
    );

    canvas.drawCircle(center, stroke * .35, Paint()..color = needleColor);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.position != position || old.bands != bands || old.min != min || old.max != max;
}
