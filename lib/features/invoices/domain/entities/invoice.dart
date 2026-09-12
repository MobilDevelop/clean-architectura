import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:equatable/equatable.dart';

/// Shartnoma bo'yicha yozilgan faktura (yuk xati).
final class Invoice extends Equatable {
  const Invoice({
    required this.id,
    required this.contractId,
    required this.partnerName,
    required this.price,
    required this.status,
    required this.waybillId,
    required this.waybillUrl,
  });

  final int id;
  final int contractId;

  /// Ta'minotchi tashkilot nomi.
  final String partnerName;

  /// So'mda.
  final int price;

  /// Shartnomaning holati. Faktura o'z holatiga ega emas — server shartnoma
  /// holatining kodini qaytaradi.
  final ContractStatus status;

  /// Yuk xati yozuvi. Faylni ochish ham, ta'minotchiga yuborish ham shunga
  /// bog'lanadi.
  final int waybillId;

  final String waybillUrl;

  /// Faylni ochish mumkinmi.
  bool get canOpen => waybillUrl.isNotEmpty;

  /// Ta'minotchiga yuborish mumkinmi.
  ///
  /// Yozuvsiz yuborib bo'lmaydi: manzilda `0` bilan so'rov ketsa server uni
  /// rad etardi va xodim sababini bilmasdi.
  bool get canSend => waybillId != 0;

  @override
  List<Object?> get props => <Object?>[id, contractId, partnerName, price, status, waybillId, waybillUrl];
}

/// Ro'yxat so'rovi.
final class InvoicesQuery extends Equatable {
  const InvoicesQuery({required this.date, required this.page});

  const InvoicesQuery.first() : date = null, page = 1;

  /// `null` — sana bo'yicha filtr yo'q, server bugungi kunni beradi.
  final DateTime? date;

  final int page;

  /// Server bir sahifada shuncha yozuv qaytaradi.
  static const int perPage = 15;

  InvoicesQuery copyWith({DateTime? date, bool clearDate = false, int? page}) => InvoicesQuery(
    date: clearDate ? null : date ?? this.date,
    page: page ?? this.page,
  );

  @override
  List<Object?> get props => <Object?>[date, page];
}

/// Bitta sahifa natijasi.
final class InvoicesPageResult extends Equatable {
  const InvoicesPageResult({required this.items, required this.isLast});

  final List<Invoice> items;

  /// Oxirgi sahifa — keyingisini so'rash kerak emas.
  final bool isLast;

  @override
  List<Object?> get props => <Object?>[items, isLast];
}
