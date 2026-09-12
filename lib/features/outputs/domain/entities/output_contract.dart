import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:equatable/equatable.dart';

/// Chiqimga tayyor shartnoma.
final class OutputContract extends Equatable {
  const OutputContract({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.phone,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.smsSentAt,
  });

  final int id;

  /// Chiqim tasdig'i shartnoma bilan birga mijozni ham talab qiladi.
  final int clientId;

  final String clientName;

  /// Faqat raqamlar.
  final String phone;

  /// So'mda.
  final int totalPrice;

  /// Holat. Ekrandagi matn shundan hisoblanadi.
  ///
  /// Backend `status` maydonida tayyor matn ham yuboradi, lekin u ekranga
  /// chiqarilmaydi: domain backend matnini uzatmaydi (3.9) va u tarjimadan
  /// ham tashqarida qolardi.
  final ContractStatus status;

  /// `dd.MM.yyyy`.
  final String createdAt;

  /// SMS kod yuborilgan payt — hisoblagich shundan sanaydi.
  ///
  /// `null` — server sanani bermadi yoki uni o'qib bo'lmadi. Bunda hisoblagich
  /// umuman chizilmaydi: noto'g'ri vaqt ko'rsatgandan ko'ra ko'rsatmagan
  /// yaxshi. Hisoblagich faqat xabar beradi, tugmani to'smaydi.
  final DateTime? smsSentAt;

  /// Chiqim berish mumkinmi.
  ///
  /// Imzolangan shartnoma tovar chiqimiga tayyor; qolgan holatlarda chiqim
  /// emas, tovarni qaytarish amali qoladi. Flex ham shu ajratishni qiladi
  /// (u status kodini `10` deb qotirib yozgan).
  bool get canRelease => status == ContractStatus.signed;

  @override
  List<Object?> get props => <Object?>[
    id,
    clientId,
    clientName,
    phone,
    totalPrice,
    status,
    createdAt,
    smsSentAt,
  ];
}

/// Chiqim shartnomasidagi tovar.
final class OutputProduct extends Equatable {
  const OutputProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.count,
    required this.price,
  });

  final int id;
  final String name;
  final String category;
  final int count;

  /// Serverdagi `price`, so'mda.
  ///
  /// Bu bitta dona narximi yoki qator summasimi — backenddan so'ralgan.
  /// Aniqlanmaguncha u ko'paytirilmaydi: `price * count` deb chiqarish
  /// javob boshqacha bo'lsa summani jimgina ikki barobar ko'rsatardi.
  /// Flex ham uni o'zgartirmasdan ko'rsatadi.
  final int price;

  @override
  List<Object?> get props => <Object?>[id, name, category, count, price];
}

/// Ro'yxat so'rovi.
///
/// Nega alohida obyekt: sana, sahifa va sahifa hajmi birga o'zgaradi va
/// usecase kirishida `Map` turmasligi kerak (3.3).
final class OutputsQuery extends Equatable {
  const OutputsQuery({required this.date, required this.page});

  const OutputsQuery.first() : date = null, page = 1;

  /// `null` — sana bo'yicha filtr yo'q.
  final DateTime? date;

  final int page;

  /// Server bir sahifada shuncha yozuv qaytaradi.
  static const int perPage = 15;

  OutputsQuery copyWith({DateTime? date, bool clearDate = false, int? page}) => OutputsQuery(
    date: clearDate ? null : date ?? this.date,
    page: page ?? this.page,
  );

  @override
  List<Object?> get props => <Object?>[date, page];
}

/// Bitta sahifa natijasi.
final class OutputsPageResult extends Equatable {
  const OutputsPageResult({required this.items, required this.isLast});

  final List<OutputContract> items;

  /// Oxirgi sahifa — keyingisini so'rash kerak emas.
  ///
  /// Nega bayroq: flex bo'sh javob kelguncha sahifani oshiraverardi, ya'ni
  /// har doim bitta ortiqcha so'rov yuborardi.
  final bool isLast;

  @override
  List<Object?> get props => <Object?>[items, isLast];
}
