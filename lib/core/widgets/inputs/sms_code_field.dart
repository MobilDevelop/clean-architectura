import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// Klaviaturani ham, cheklovchini ham shu tanlov boshqaradi — ikkisi
/// hech qachon bir-biridan ajralmasligi uchun.
enum SmsCodeKind {
  digits,
  alphanumeric;

  TextInputType get keyboard => this == digits ? TextInputType.number : TextInputType.text;

  TextInputFormatter get filter => this == digits
      ? FilteringTextInputFormatter.digitsOnly
      : FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]'));
}

/// SMS kod kiritish maydoni.
///
/// Kod **mijozning** telefoniga keladi va xodim uni eshitib yozadi — har
/// belgi alohida katakda bo'lsa nechtasi kiritilgani sanalmaydi.
///
/// `length` berilmasa kataklar chizilmaydi: nechtasini bilmay turib ularni
/// ko'rsatish yolg'on bo'ladi.
final class SmsCodeField extends StatefulWidget {
  const SmsCodeField({
    super.key,
    required this.controller,
    required this.kind,
    this.onChanged,
    this.length,
    this.errorText,
    this.hint,
    this.enabled = true,
    this.autoFocus = false,
  });

  final TextEditingController controller;
  final SmsCodeKind kind;
  final ValueChanged<String>? onChanged;

  /// Kod uzunligi. `null` — uzunlik noma'lum.
  final int? length;

  final String? errorText;

  /// Faqat uzunlik noma'lum bo'lganda ko'rinadi.
  final String? hint;

  final bool enabled;
  final bool autoFocus;

  @override
  State<SmsCodeField> createState() => _SmsCodeFieldState();
}

final class _SmsCodeFieldState extends State<SmsCodeField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_redraw);
    _focus.addListener(_redraw);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_redraw);
    _focus
      ..removeListener(_redraw)
      ..dispose();
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final int? count = widget.length;

    if (count == null) return _plain();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _cells(count),

        if (widget.errorText case final String error) ...<Widget>[
          Gap(ScreenSize.h6),
          Padding(
            padding: EdgeInsets.only(left: ScreenSize.w10),
            child: Text(
              error,
              style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.red),
            ),
          ),
        ],
      ],
    );
  }

  Widget _plain() => TextInputWidget(
    hint: widget.hint ?? '',
    controller: widget.controller,
    errorText: widget.errorText,
    enabled: widget.enabled,
    autoFocus: widget.autoFocus,
    keyboardType: widget.kind.keyboard,
    formatters: <TextInputFormatter>[widget.kind.filter],
    onChanged: widget.onChanged,
  );

  /// Bitta ko'rinmas maydon kataklar ustida turadi. Har katakka bittadan
  /// maydon qo'yilsa fokus, o'chirish va qo'yish qo'lda yozilardi.
  Widget _cells(int count) {
    final String code = widget.controller.text;

    return Stack(
      children: <Widget>[
        Row(
          children: <Widget>[
            for (int index = 0; index < count; index++) ...<Widget>[
              if (index > 0) Gap(ScreenSize.w8),
              Expanded(child: _cell(index, code)),
            ],
          ],
        ),

        Positioned.fill(child: _input(count)),
      ],
    );
  }

  Widget _cell(int index, String code) {
    final bool isFilled = index < code.length;
    final bool isActive = _focus.hasFocus && widget.enabled && index == code.length;
    final bool hasError = widget.errorText != null;

    return Container(
      height: ScreenSize.h52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.colors.backcolor,
        borderRadius: BorderRadius.circular(ScreenSize.r14),
        border: switch ((hasError, isActive)) {
          (true, _) => Border.all(color: AppTheme.colors.red),
          (false, true) => Border.all(color: AppTheme.colors.primary, width: 1.5),
          (false, false) => AppSurface.border(),
        },
      ),
      child: Text(
        isFilled ? code[index] : '',
        style: AppTheme.data.textTheme.headlineLarge?.copyWith(
          color: AppTheme.colors.blackSoft,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _input(int count) => TextField(
    controller: widget.controller,
    focusNode: _focus,
    enabled: widget.enabled,
    autofocus: widget.autoFocus,
    keyboardType: widget.kind.keyboard,
    inputFormatters: <TextInputFormatter>[
      widget.kind.filter,
      LengthLimitingTextInputFormatter(count),
    ],
    onChanged: widget.onChanged,
    // Matnni kataklar ko'rsatadi.
    showCursor: false,
    style: const TextStyle(color: Colors.transparent),
    cursorColor: Colors.transparent,
    enableInteractiveSelection: false,
    textAlign: TextAlign.center,
    decoration: const InputDecoration(
      isCollapsed: true,
      border: InputBorder.none,
      counterText: '',
    ),
  );
}
