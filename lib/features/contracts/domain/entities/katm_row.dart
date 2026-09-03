import 'package:equatable/equatable.dart';

/// Jadvaldagi bitta maydon.
///
/// KATM hujjatida bir qatorda 71 tagacha maydon bo'lishi mumkin va ustunlar
/// backenddan kelgan maketga qarab tanlanadi. Shuning uchun qator maydonlar
/// ro'yxati sifatida saqlanadi — `Map` entityda turmaydi (3.2).
final class KatmField extends Equatable {
  const KatmField({required this.key, required this.value, required this.isMoney});

  final String key;
  final String value;

  /// Summa maydonlari alohida formatlanadi va so'mga aylantirilgan holda keladi.
  final bool isMoney;

  @override
  List<Object?> get props => [key, value, isMoney];
}

/// Qator ichidagi ro'yxat: oylik qoldiqlar, to'lov jadvallari, ta'minotlar.
///
/// Bitta shartnomada yuzlab element bo'lishi mumkin, shuning uchun ular faqat
/// tafsilot ochilganda chiziladi.
final class KatmNested extends Equatable {
  const KatmNested({required this.key, required this.rows});

  final String key;
  final List<KatmRow> rows;

  @override
  List<Object?> get props => [key, rows];
}

final class KatmRow extends Equatable {
  const KatmRow(this.fields, {this.nested = const <KatmNested>[]});

  final List<KatmField> fields;
  final List<KatmNested> nested;

  KatmField? field(String key) {
    for (final KatmField item in fields) {
      if (item.key == key) return item;
    }

    return null;
  }

  String valueOf(String key) => field(key)?.value ?? '';

  List<KatmRow> nestedOf(String key) {
    for (final KatmNested item in nested) {
      if (item.key == key) return item.rows;
    }

    return const <KatmRow>[];
  }

  bool get hasNested => nested.any((KatmNested item) => item.rows.isNotEmpty);

  bool get isEmpty => fields.isEmpty;

  @override
  List<Object?> get props => [fields, nested];
}
