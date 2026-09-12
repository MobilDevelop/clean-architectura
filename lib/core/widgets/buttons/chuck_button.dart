import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// Tarmoq so'rovlarini ko'rish tugmasi (faqat staging'da).
///
/// Inspektorni o'zi ochmaydi — ochish amalini tashqaridan oladi (8.1).
/// Ilgari bu yerda `getIt<Alice>()` turardi: klass ichidagi `getIt` testda
/// o'rniga soxta obyekt qo'yishga imkon bermaydi va widgetni tashxis
/// kutubxonasiga bog'lab qo'yadi.
final class ChuckButton extends StatefulWidget {
  const ChuckButton({super.key, required this.inspectPress});

  final VoidCallback inspectPress;

  @override
  State<ChuckButton> createState() => _ChuckButtonState();
}

final class _ChuckButtonState extends State<ChuckButton> {
  late double _top;
  double _right = ScreenSize.h20;
  bool _placed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Boshlang'ich joyi status bar balandligiga bog'liq: iOS'dagi Dynamic Island
    // Android status baridan baland, qattiq 40 raqami tugmani uning tagida qoldiradi.
    if (_placed) return;
    _top = MediaQuery.of(context).viewPadding.top + ScreenSize.h8;
    _placed = true;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _top,
      right: _right,
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          setState(() {
            _top += details.delta.dy;
            _right -= details.delta.dx;
          });
        },
        onTap: widget.inspectPress,
        child: Material(
          elevation: 4,
          shape: const CircleBorder(),
          color: AppTheme.colors.primary,
          child: Padding(
            padding: EdgeInsets.all(ScreenSize.h12),
            child: Icon(Icons.http, color: AppTheme.colors.white, size: ScreenSize.h28),
          ),
        ),
      ),
    );
  }
}
