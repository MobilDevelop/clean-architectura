import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/thousand_separator_formatter.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_forms.dart';
import 'package:colloborator_v3/features/underwriter/presentation/styles/underwriter_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// Oxirgi olti oylik ish haqi.
///
/// Kontrollerlar shu yerda yashaydi va serverdan yangi qiymat kelganda
/// yangilanadi — saqlashdan keyin ekran o'zi qayta o'qiydi.
final class SalarySection extends StatefulWidget {
  const SalarySection({super.key, required this.rows, required this.amountChanged});

  final List<SalaryRow> rows;
  final void Function(int index, int amount) amountChanged;

  @override
  State<SalarySection> createState() => _SalarySectionState();
}

final class _SalarySectionState extends State<SalarySection> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.rows.map((SalaryRow e) => TextEditingController(text: _text(e.amount))).toList();
  }

  @override
  void didUpdateWidget(covariant SalarySection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.rows.length != _controllers.length) {
      for (final TextEditingController c in _controllers) {
        c.dispose();
      }
      _controllers = widget.rows.map((SalaryRow e) => TextEditingController(text: _text(e.amount))).toList();

      return;
    }

    // Faqat haqiqatan boshqa qiymat kelganda yoziladi: aks holda terayotgan
    // paytda kursor boshiga sakrab ketadi.
    for (int i = 0; i < widget.rows.length; i++) {
      if (Money.parse(_controllers[i].text) != widget.rows[i].amount) {
        _controllers[i].text = _text(widget.rows[i].amount);
      }
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _text(int amount) => amount == 0 ? '' : Money.format(amount);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int i = 0; i < widget.rows.length; i++) ...<Widget>[
          if (i > 0) Gap(ScreenSize.h10),
          Row(
            children: <Widget>[
              SizedBox(
                width: ScreenSize.h96,
                child: Text(
                  UnderwriterText.month(widget.rows[i].year, widget.rows[i].month),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.bodySmall,
                ),
              ),

              Gap(ScreenSize.w8),
              Expanded(
                child: TextInputWidget(
                  hint: "0",
                  controller: _controllers[i],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  formatters: <TextInputFormatter>[ThousandsSeparatorInputFormatter()],
                  onChanged: (String value) => widget.amountChanged(i, Money.parse(value)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
