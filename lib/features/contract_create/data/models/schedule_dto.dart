import 'package:colloborator_v3/features/contract_create/domain/entities/payment_schedule.dart';

/// `dd-MM-yyyy` → sana. Format mos kelmasa `null`.
///
/// Nega istisno otilmaydi: bitta qatorning sanasi buzilgani butun jadvalni
/// yo'qotishi kerak emas. Qator baribir ko'rinadi, faqat sanasiz.
DateTime? _date(Object? raw) {
  final List<String> parts = raw?.toString().split('-') ?? const <String>[];
  if (parts.length != 3) return null;

  final int? day = int.tryParse(parts[0]);
  final int? month = int.tryParse(parts[1]);
  final int? year = int.tryParse(parts[2]);

  if (day == null || month == null || year == null) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;

  return DateTime(year, month, day);
}

final class ScheduleRowDto {
  const ScheduleRowDto(this._json);

  factory ScheduleRowDto.fromJson(Map<String, dynamic> json) => ScheduleRowDto(json);

  final Map<String, dynamic> _json;

  ScheduleRow toEntity() => ScheduleRow(
    number: _json['number'] as int? ?? 0,
    date: _date(_json['date']),
    // Summa so'mda keladi (DEV-4085) — bo'linmaydi.
    amount: (num.tryParse(_json['value']?.toString() ?? '') ?? 0).toInt(),
  );
}
