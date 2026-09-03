import 'dart:io';

import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';
import 'package:colloborator_v3/features/customers/domain/entities/face_check_params.dart';
import 'package:equatable/equatable.dart';

enum FaceCheckIssue { none, offerNotAccepted, incompleteSeries, incompleteNumber, incompleteDate, invalidDate, futureDate, tooYoung }

/// Rasm olinishidan oldingi holat: faqat qo'lda kiritiladigan maydonlar.
/// Tekshiruv shu yerda, chunki u rasmga bog'liq emas — kamera ochilishidan
/// oldin ishlashi kerak.
final class FaceCheckForm extends Equatable {
  const FaceCheckForm({this.series = '', this.number = '', this.birthday = ''});

  /// Pasport seriyasi: `AA`.
  final String series;

  /// Pasport raqami: `1234567`.
  final String number;

  /// `dd.MM.yyyy` — backend aynan shu formatni kutadi.
  final String birthday;

  static const int _dateLength = 10;
  static const String _dateSeparator = '.';

  /// Pasport 16 yoshda beriladi.
  static const int passportAge = 16;

  /// Sana tanlagichning yuqori chegarasi. Qoida bitta joyda turishi uchun
  /// tanlagich ham shu yerdan hisoblanadi.
  static DateTime latestBirthday(DateTime today) => DateTime(today.year - passportAge, today.month, today.day);

  /// Backend seriya va raqamni bitta maydonda kutadi.
  String get passport => '$series$number';

  /// Kiritilgan sana — noto'g'ri bo'lsa `null`. Taqvim shu kundan ochiladi.
  DateTime? get birthdayDate => _birthdayOrNull();

  /// Bugungi kun tashqaridan beriladi, aks holda yosh qoidasini test qilib
  /// bo'lmaydi (9.4).
  FaceCheckIssue issueAt(DateTime today) {
    if (series.length != CustomerSearchShape.passportLetters) return FaceCheckIssue.incompleteSeries;
    if (number.length != CustomerSearchShape.passportDigits) return FaceCheckIssue.incompleteNumber;
    if (birthday.length != _dateLength) return FaceCheckIssue.incompleteDate;

    final DateTime? date = _birthdayOrNull();
    if (date == null) return FaceCheckIssue.invalidDate;

    if (date.isAfter(today)) return FaceCheckIssue.futureDate;
    if (latestBirthday(today).isBefore(date)) return FaceCheckIssue.tooYoung;

    return FaceCheckIssue.none;
  }

  FaceCheckParams withImage(File image) => FaceCheckParams(passport: passport, birthday: birthday, image: image);

  FaceCheckForm copyWith({String? series, String? number, String? birthday}) => FaceCheckForm(
    series: series ?? this.series,
    number: number ?? this.number,
    birthday: birthday ?? this.birthday,
  );

  DateTime? _birthdayOrNull() {
    final List<String> parts = birthday.split(_dateSeparator);
    if (parts.length != 3) return null;

    final int? day = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    final int? year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;

    final DateTime date = DateTime(year, month, day);

    // `DateTime(2000, 2, 31)` xato bermaydi — 2-martga surib yuboradi.
    if (date.year != year || date.month != month || date.day != day) return null;

    return date;
  }

  @override
  List<Object?> get props => [series, number, birthday];
}
