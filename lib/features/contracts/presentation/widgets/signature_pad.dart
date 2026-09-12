import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// Imzo chizadigan maydon.
///
/// Nega kutubxona emas: kerak bo'lgani — nuqtalarni yig'ish va PNG ga
/// o'girish. Buning uchun `CustomPaint` yetarli, yangi bog'liqlik esa
/// platformaga sozlash olib keladi.
final class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key, required this.isLocked});

  /// Yozuv ketayotganda chizishga ruxsat berilmaydi: yuborilgan imzo bilan
  /// ekrandagi imzo boshqa-boshqa bo'lib qolardi.
  final bool isLocked;

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

final class SignaturePadState extends State<SignaturePad> {
  /// `null` — qalam ko'tarilgan joy, ya'ni chiziq uzilishi.
  final List<Offset?> _points = <Offset?>[];

  final GlobalKey _boundary = GlobalKey();

  static const double _stroke = 2.5;

  bool get hasSignature => _points.any((Offset? point) => point != null);

  void clear() => setState(_points.clear);

  /// Chizilganini PNG baytlariga o'giradi.
  ///
  /// `RenderRepaintBoundary` emas, `PictureRecorder`: ekrandagi o'lchamdan
  /// qat'i nazar bir xil rasm chiqadi va oq fon aniq beriladi — shaffof PNG
  /// serverdagi hujjatda ko'rinmay qolardi.
  Future<Uint8List?> export() async {
    final RenderBox? box = _boundary.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !hasSignature) return null;

    // Maydon klaviatura ochilganda kichrayadi, nuqtalar esa to'liq
    // o'lchamdagi koordinatalarda chizilgan. Faqat joriy o'lchamga tayansak,
    // klaviatura ochiq holda yuborilgan imzoning pasti kesilib qolardi.
    final Size size = _canvasFor(box.size);

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    _SignaturePainter(_points).paint(canvas, size);

    final ui.Image image = await recorder.endRecording().toImage(size.width.round(), size.height.round());
    final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    return data?.buffer.asUint8List();
  }

  /// Barcha nuqtalarni qamrab oladigan o'lcham.
  Size _canvasFor(Size box) {
    double width = box.width;
    double height = box.height;

    for (final Offset? point in _points) {
      if (point == null) continue;

      width = math.max(width, point.dx + _stroke);
      height = math.max(height, point.dy + _stroke);
    }

    return Size(width, height);
  }

  void _add(Offset? point) {
    if (widget.isLocked) return;

    setState(() => _points.add(point));
  }

  @override
  Widget build(BuildContext context) {
    // O'lchamni ota-ona beradi: maydon qancha katta bo'lsa, imzo shuncha aniq
    // chiqadi. Ilgari u 160px lik tasma edi va scroll qiladigan ro'yxat ichida
    // turardi — vertikal harakat uchun ikkita da'vogar bo'lib, bazida chizish
    // o'rniga ro'yxat surilardi.
    return Container(
      key: _boundary,
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r14),
        border: AppSurface.border(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ScreenSize.r14),
        // `opaque` shart: sukut bo'yicha `deferToChild` ishlaydi va u faqat
        // bolaning egallagan joyini hisobga oladi. Ko'rsatma matni maydonning
        // o'rtasidagina, chizilgandan keyin esa bola umuman yo'q — ya'ni
        // maydonning katta qismida barmoq sezilmasdi.
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (DragStartDetails d) => _add(d.localPosition),
          onPanUpdate: (DragUpdateDetails d) => _add(d.localPosition),
          onPanEnd: (DragEndDetails _) => _add(null),
          child: CustomPaint(
            painter: _SignaturePainter(_points),
            size: Size.infinite,
            child: hasSignature
                ? null
                : Center(
                    child: Text(
                      "Shu yerga imzo qo'ying",
                      style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: AppTheme.colors.grey),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

final class _SignaturePainter extends CustomPainter {
  const _SignaturePainter(this.points);

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = SignaturePadState._stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      final Offset? from = points[i];
      final Offset? to = points[i + 1];

      if (from != null && to != null) canvas.drawLine(from, to, paint);
    }
  }

  /// Har doim qayta chiziladi.
  ///
  /// Nuqtalar ro'yxati **joyida** o'zgartiriladi, ya'ni `oldDelegate.points`
  /// bilan `points` — bitta obyekt. Ular ustidagi har qanday solishtiruv
  /// (uzunlik ham, mazmun ham) doim "o'zgarmadi" deb javob beradi va imzo
  /// ekranda umuman ko'rinmaydi.
  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
