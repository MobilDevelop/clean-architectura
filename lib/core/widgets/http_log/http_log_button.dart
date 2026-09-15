import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// HTTP jurnalini ochuvchi suriladigan tugma (faqat staging'da).
///
/// Jurnalni o'zi ochmaydi — ochish amalini tashqaridan oladi (8.1).
final class HttpLogButton extends StatefulWidget {
  const HttpLogButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<HttpLogButton> createState() => _HttpLogButtonState();
}

final class _HttpLogButtonState extends State<HttpLogButton> {
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
        onTap: widget.onPressed,
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
