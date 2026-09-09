import 'package:equatable/equatable.dart';

/// Daromad hujjatining turi.
///
/// `code` serverga `type` maydoni sifatida ketadi. Flex UI'da bu bo'lim
/// "Guvohnoma" deb ataladi, lekin serverga `military` yuboriladi — nom va kod
/// bir-biriga aralashib ketmasligi uchun ikkalasi shu yerda ajratilgan.
enum UnderwriterKind {
  salary('salary'),
  pension('pension'),
  military('military'),
  student('student'),
  car('car');

  const UnderwriterKind(this.code);

  final String code;
}

/// Bo'limni saqlashga to'sqinlik qiladigan kamchilik.
enum UnderwriterIssue {
  none,
  noFiles,
  amountMissing,
  positionMissing,
  brandMissing,
  modelMissing,
  yearMissing,
}

/// Fayl qo'shishga to'sqinlik qiladigan sabab.
enum FileIssue { none, tooMany, tooLarge, wrongType }

/// Hujjat fayli uchun chegaralar.
///
/// Domainda: backend ham shu qoidalarni tekshiradi (7.3).
abstract final class UnderwriterFileRule {
  static const int maxCount = 3;

  /// Bayt. Flex 1.9 MB ni chegara qilib olgan — 2 MB dagi serverga tegmasin
  /// uchun ozgina zaxira qoldirilgan.
  static const int maxBytes = 1992294;

  static const Set<String> extensions = <String>{'pdf', 'jpg', 'jpeg', 'png'};

  /// Kengaytmadan MIME. S3 ga aynan shu `Content-Type` bilan yuboriladi.
  static String mimeOf(String extension) => switch (extension.toLowerCase()) {
    'pdf' => 'application/pdf',
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    _ => 'application/octet-stream',
  };

  static FileIssue check({required int count, required int bytes, required String extension}) {
    if (count >= maxCount) return FileIssue.tooMany;
    if (!extensions.contains(extension.toLowerCase())) return FileIssue.wrongType;
    if (bytes > maxBytes) return FileIssue.tooLarge;

    return FileIssue.none;
  }
}

/// Ma'lumotnoma elementi: avtomobil brendi, markasi, ishlab chiqarilgan yili.
final class UnderwriterOption extends Equatable {
  const UnderwriterOption({required this.id, required this.name});

  /// `0` — tanlanmagan.
  final int id;
  final String name;

  bool get isEmpty => id == 0;

  @override
  List<Object?> get props => [id, name];
}

/// Harbiy lavozim. Summa foydalanuvchidan emas, lavozimdan olinadi.
final class MilitaryPosition extends Equatable {
  const MilitaryPosition({required this.id, required this.name, required this.amount});

  final int id;
  final String name;

  /// Serverga `sum` sifatida ketadi.
  final int amount;

  bool get isEmpty => id == 0;

  @override
  List<Object?> get props => [id, name, amount];
}
