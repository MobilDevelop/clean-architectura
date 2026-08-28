import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

final class DotWidget extends StatelessWidget {
  const DotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: _top, right: _right, child: _buildDotWidget),
        Positioned(bottom: _bottom, right: _right, child: _buildDotWidget),
        Positioned(top: _top, left: _left, child: _buildDotWidget),
        Positioned(bottom: _bottom, left: _left, child: _buildDotWidget),
      ],
    );
  }
}
const double _top = 10.0;
const double _bottom = 12.0;
const double _right = 8.0;
const double _left = 8.0;

Widget get _buildDotWidget => Container(
  height: 10,
  width: 10,
  decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.colors.primary),
);
