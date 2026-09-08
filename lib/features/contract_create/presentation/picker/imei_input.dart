import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// IMEI ro'yxati. Har bir nusxa alohida raqamlanadi, shuning uchun miqdor
/// alohida kiritilmaydi — u shu ro'yxatning uzunligi.
final class ImeiInput extends StatefulWidget {
  const ImeiInput({super.key, required this.imeis, required this.onAdded, required this.onRemoved, this.errorText});

  final List<String> imeis;
  final ValueChanged<String> onAdded;
  final ValueChanged<String> onRemoved;
  final String? errorText;

  @override
  State<ImeiInput> createState() => _ImeiInputState();
}

final class _ImeiInputState extends State<ImeiInput> {
  late final TextEditingController _controller;

  /// IMEI — 15 raqam.
  static const int _length = 15;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final String value = _controller.text.trim();
    if (value.isEmpty) return;

    widget.onAdded(value);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: TextInputWidget(
                controller: _controller,
                title: "IMEI",
                hint: "15 ta raqam",
                keyboardType: TextInputType.number,
                errorText: widget.errorText,
                formatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_length),
                ],
                onSubmitted: (String _) => _add(),
              ),
            ),

            Gap(ScreenSize.w10),
            Padding(
              padding: EdgeInsets.only(top: ScreenSize.h24),
              child: InkWell(
                onTap: _add,
                borderRadius: BorderRadius.circular(ScreenSize.r14),
                child: Container(
                  height: ScreenSize.h48,
                  width: ScreenSize.h48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(ScreenSize.r14),
                    border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .25)),
                  ),
                  child: Icon(Icons.add_rounded, color: AppTheme.colors.primary, size: ScreenSize.h22),
                ),
              ),
            ),
          ],
        ),

        if (widget.imeis.isNotEmpty) ...<Widget>[
          Gap(ScreenSize.h10),
          Wrap(
            spacing: ScreenSize.w8,
            runSpacing: ScreenSize.h8,
            children: widget.imeis.map(_chip).toList(),
          ),

          Gap(ScreenSize.h6),
          Text("${widget.imeis.length} ta nusxa", style: AppTheme.data.textTheme.bodySmall),
        ],
      ],
    );
  }

  Widget _chip(String value) => Container(
    padding: EdgeInsets.only(left: ScreenSize.h10, right: ScreenSize.h4, top: ScreenSize.h4, bottom: ScreenSize.h4),
    decoration: BoxDecoration(
      color: AppTheme.colors.backcolor,
      borderRadius: BorderRadius.circular(ScreenSize.r12),
      border: AppSurface.border(alpha: .6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(value, style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: AppTheme.colors.blackSoft)),

        Gap(ScreenSize.w4),
        InkWell(
          onTap: () => widget.onRemoved(value),
          borderRadius: BorderRadius.circular(ScreenSize.r10),
          child: Padding(
            padding: EdgeInsets.all(ScreenSize.h2),
            child: Icon(Icons.close_rounded, size: ScreenSize.h16, color: AppTheme.colors.grey),
          ),
        ),
      ],
    ),
  );
}
