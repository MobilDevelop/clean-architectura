
import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/alice.dart';

class ChuckButton extends StatefulWidget {
  const ChuckButton({super.key});

  @override
  State<ChuckButton> createState() => _ChuckButtonState();
}

class _ChuckButtonState
    extends State<ChuckButton> {
  late double _top;
  double _right = 20;
  bool _placed = false;

  final alice = getIt<Alice>();

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
      child:GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _top += details.delta.dy;
            _right -= details.delta.dx;
          });
        },
        onTap: ()=>alice.showInspector(),
        child: Material(
          elevation: 4,
          shape: const CircleBorder(),
          color: AppTheme.colors.primary,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.http,color: Colors.white,size: 28),
          ),
        ),
      ),
    );
  }
}