import 'package:flutter/services.dart';

/// Marja maydoniga `max`dan katta raqam kiritilishiga yo'l qo'ymaydi.
///
/// Nega alohida: faqat shu ekranda kerak (1.2) — front va bek marjaning
/// chegarasi boshqa-boshqa (20% va 100%).
final class MaxPercentFormatter extends TextInputFormatter {
  const MaxPercentFormatter({required this.max});

  final int max;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final int? value = int.tryParse(newValue.text);
    if (value == null || value > max) return oldValue;

    return newValue;
  }
}
