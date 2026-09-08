import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_form.dart';
import 'package:equatable/equatable.dart';

/// Shartnomaning kam ishlatiladigan va shartli qismlari.
///
/// Ular tabga tiqilmaydi: har biri o'z ekranida ochiladi. Aks holda asosiy
/// ekran shartli bloklar bilan cheksiz o'sadi — flex'da aynan shu bo'lgan.
enum ContractExtra { schedule, tariff, underwriter, bonus, katmSkip }

/// Nega hozircha ochib bo'lmaydi. Matn presentationda (3.9).
enum ContractExtraBlock { none, noContract, noProducts, noPaymentDay }

final class ContractExtraRow extends Equatable {
  const ContractExtraRow({required this.extra, this.block = ContractExtraBlock.none});

  final ContractExtra extra;
  final ContractExtraBlock block;

  bool get isOpen => block == ContractExtraBlock.none;

  @override
  List<Object?> get props => [extra, block];
}

/// Qaysi qo'shimcha ekran ko'rinishi va qaysi biri hali ochilmasligi.
///
/// Widget bu qarorni qabul qilmaydi, faqat chizadi (6.7).
final class ContractExtras extends Equatable {
  const ContractExtras(this.rows);

  /// KATM/MIB tekshiruvini o'tkazib yuborish faqat shu statusda taklif
  /// qilinadi (flex: `product_add_page.dart:81`).
  static const int katmSkipStatus = 5;

  factory ContractExtras.of({
    required ContractDetails? details,
    required ContractForm form,
    required bool canSkipKatm,
  }) {
    final bool hasContract = details != null;
    final bool hasProducts = (details?.products.length ?? 0) > 0;

    ContractExtraBlock blockOf({bool needsProducts = false, bool needsPaymentDay = false}) {
      if (!hasContract) return ContractExtraBlock.noContract;
      if (needsProducts && !hasProducts) return ContractExtraBlock.noProducts;
      if (needsPaymentDay && form.paymentDay == 0) return ContractExtraBlock.noPaymentDay;

      return ContractExtraBlock.none;
    }

    final List<ContractExtraRow> rows = <ContractExtraRow>[
      ContractExtraRow(
        extra: ContractExtra.schedule,
        block: blockOf(needsProducts: true, needsPaymentDay: true),
      ),

      // Tarif ro'yxati shartnoma summasiga bog'liq — tovarsiz so'ralmaydi.
      ContractExtraRow(extra: ContractExtra.tariff, block: blockOf(needsProducts: true)),

      ContractExtraRow(extra: ContractExtra.underwriter, block: blockOf()),
    ];

    if (details?.benefit != null) {
      rows.add(ContractExtraRow(extra: ContractExtra.bonus, block: blockOf()));
    }

    if (canSkipKatm && details?.statusCode == katmSkipStatus) {
      rows.add(ContractExtraRow(extra: ContractExtra.katmSkip, block: blockOf()));
    }

    return ContractExtras(rows);
  }

  final List<ContractExtraRow> rows;

  @override
  List<Object?> get props => [rows];
}
