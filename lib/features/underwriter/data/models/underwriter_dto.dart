import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_data.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_file.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_forms.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';

int _int(Object? raw) => raw == null ? 0 : (num.tryParse(raw.toString()) ?? 0).toInt();

Map<String, dynamic> _object(Object? raw) => raw is Map<String, dynamic> ? raw : const <String, dynamic>{};

/// `urls` — oddiy satrlar ro'yxati, ya'ni S3 kalitlari.
List<UnderwriterFile> _files(Object? raw) {
  final List<dynamic> list = raw is List ? raw : const <dynamic>[];

  return list
      .map((Object? e) => e?.toString() ?? '')
      .where((String e) => e.isNotEmpty)
      .map(UnderwriterFile.stored)
      .toList();
}

final class MilitaryPositionDto {
  const MilitaryPositionDto(this._json);

  factory MilitaryPositionDto.fromJson(Map<String, dynamic> json) => MilitaryPositionDto(json);

  final Map<String, dynamic> _json;

  MilitaryPosition toEntity() => MilitaryPosition(
    id: _int(_json['id']),
    name: _json['name']?.toString() ?? '',
    // Summa lavozimdan olinadi — foydalanuvchi uni kiritmaydi.
    amount: _int(_json['amount']),
  );
}

final class OptionDto {
  const OptionDto(this._json);

  factory OptionDto.fromJson(Map<String, dynamic> json) => OptionDto(json);

  final Map<String, dynamic> _json;

  UnderwriterOption toEntity() =>
      UnderwriterOption(id: _int(_json['id']), name: _json['name']?.toString() ?? '');
}

/// `POST upload-s3-url` javobi. `data` o'ramisiz keladi.
final class FileDirectionDto {
  const FileDirectionDto(this._json);

  factory FileDirectionDto.fromJson(Map<String, dynamic> json) => FileDirectionDto(json);

  final Map<String, dynamic> _json;

  String get uploadUrl => _json['upload_url']?.toString() ?? '';

  String get fileKey => _json['file_key']?.toString() ?? '';
}

/// `GET underwriters?contract_id=` javobi.
///
/// Diqqat: bu endpoint javobni `data` ichida emas, **yuqori darajada**
/// qaytaradi — servisdagi boshqa hamma chaqiruvdan farqli.
final class UnderwriterDataDto {
  const UnderwriterDataDto(this._json);

  factory UnderwriterDataDto.fromJson(Map<String, dynamic> json) => UnderwriterDataDto(json);

  /// Javobning yuqori darajasi uch xil bo'lishi mumkin:
  ///
  /// * obyekt — saqlangan bo'limlar bor;
  /// * `null` yoki **bo'sh ro'yxat** — hali hech nima saqlanmagan. Server bo'sh
  ///   to'plamni obyekt emas, `[]` qilib qaytaradi;
  /// * boshqa hamma narsa — buzuq javob. U jimgina "bo'sh" ga aylantirilmaydi,
  ///   aks holda foydalanuvchi to'ldirilgan bo'limlarni bo'sh ko'rardi (5.8).
  static UnderwriterDataDto? tryFrom(Object? raw) {
    if (raw == null) return null;
    if (raw is List && raw.isEmpty) return null;
    if (raw is Map) return UnderwriterDataDto(Map<String, dynamic>.from(raw));

    throw FormatException('underwriters javobi obyekt emas: ${raw.runtimeType}');
  }

  final Map<String, dynamic> _json;

  UnderwriterData toEntity() {
    final Map<String, dynamic> salary = _object(_json['salary']);
    final Map<String, dynamic> pension = _object(_json['pension']);
    final Map<String, dynamic> student = _object(_json['student']);
    final Map<String, dynamic> military = _object(_json['military']);
    final Map<String, dynamic> car = _object(_json['car']);

    return UnderwriterData(
      // Qatorlar bo'sh kelsa oylar bloc'da yaratiladi: ular bugungi sanaga
      // bog'liq va DTO soatga qaramasligi kerak (9.4).
      salary: SalaryForm(
        editId: _int(salary['id']),
        files: _files(salary['urls']),
        rows: _rows(salary['sum']),
      ),
      pension: PensionForm(
        editId: _int(pension['id']),
        files: _files(pension['urls']),
        amount: _int(pension['sum']),
      ),
      student: StudentForm(editId: _int(student['id']), files: _files(student['urls'])),
      // Lavozim ichma-ich obyektda keladi: `military: { id, urls, rank: {...} }`.
      // Yuborishda esa u tekis `rank_id` bo'lib ketadi — kalitlar assimetrik
      // (flex `certificate_edit.dart:21` va `military_model.dart:15`).
      military: MilitaryForm(
        editId: _int(military['id']),
        files: _files(military['urls']),
        position: () {
          final Map<String, dynamic> rank = _object(military['rank']);

          return MilitaryPosition(
            id: _int(rank['id']),
            name: rank['name']?.toString() ?? '',
            amount: _int(rank['amount']),
          );
        }(),
      ),
      // Bu yerda ham assimetriya: id `car_brand_id`, nomi esa `brand_name`
      // (flex `auto_income.dart:63`).
      car: CarForm(
        editId: _int(car['id']),
        files: _files(car['urls']),
        brand: UnderwriterOption(
          id: _int(car['car_brand_id']),
          name: car['brand_name']?.toString() ?? '',
        ),
        model: UnderwriterOption(
          id: _int(car['car_model_id']),
          name: car['model_name']?.toString() ?? '',
        ),
        year: _int(car['manufacture_year']),
      ),
    );
  }

  List<SalaryRow> _rows(Object? raw) {
    final List<dynamic> list = raw is List ? raw : const <dynamic>[];

    return list
        .whereType<Map<String, dynamic>>()
        .map(
          (Map<String, dynamic> e) =>
              SalaryRow(year: _int(e['year']), month: _int(e['month']), amount: _int(e['salary'])),
        )
        .toList();
  }
}
