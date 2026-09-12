import 'package:colloborator_v3/features/contracts/domain/entities/contract_authority.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:equatable/equatable.dart';

/// Shartnoma bosilganda nima ochilishi.
enum ContractTap {
  /// Status 40 — daromad turi tanlanmagan.
  selectIncome,

  /// Status 24, 25 — SMS kodi kutilmoqda yoki xatolik aniqlangan.
  confirmSms,

  /// Status 11 — shartnoma tasdiqlangan, faqat ko'rish uchun ochiladi.
  viewProduct,

  /// Qolgan hamma holat — amallar oynasi.
  showActions,
}

/// Birinchi tugmaning ma'nosi. Uchtasidan bittasi bo'ladi.
enum ApproveAction {
  /// Imzolash oqimiga o'tadi — so'rov yuborilmaydi.
  proceed,

  /// O'ziga kelgan shartnomaga ruxsat berish.
  allow,

  /// Vakolatli shaxsga yo'naltirish.
  escalate,
}

/// Amallar oynasidagi tugmalar holati.
///
/// Nega domainda: qaysi tugma qanday ma'no olishi biznes qoidasi. Matritsa
/// dvijogida uni server aytadi, eski dvijokda shartnomaning bayroqlaridan
/// hisoblanadi. Widget hisoblamaydi, faqat ko'rsatadi (6.7).
final class ContractActions extends Equatable {
  const ContractActions({
    required this.approve,
    required this.canApprove,
    required this.canEdit,
    required this.canCancel,
    required this.isReady,
    required this.warning,
  });

  factory ContractActions.of(ContractInfo contract, {ContractAuthority? authority}) {
    final bool isMatrix = contract.engine == AuthorityEngine.matrix;

    // Matritsada javob kelmaguncha hech narsa ma'lum emas.
    if (isMatrix && authority == null) {
      return const ContractActions(
        approve: ApproveAction.proceed,
        canApprove: false,
        canEdit: false,
        canCancel: false,
        isReady: false,
        warning: '',
      );
    }

    final bool canAllow = isMatrix ? authority?.canApprove ?? false : contract.canUserAllowConfirmation;
    final bool canEscalate = isMatrix
        ? authority?.canEscalate ?? false
        : contract.higherPositionConfirmationRequired;

    final ApproveAction action = canAllow
        ? ApproveAction.allow
        : canEscalate
        ? ApproveAction.escalate
        : ApproveAction.proceed;

    final bool canProceed = isMatrix ? authority?.canProceed ?? false : !(canAllow || canEscalate);

    return ContractActions(
      approve: action,
      // Matritsada faollikni server hal qiladi, eski dvijokda status bo'yicha.
      canApprove: isMatrix ? canProceed || canAllow || canEscalate : _approveStatuses.contains(contract.statusCode),
      canEdit: _canEdit(contract),
      canCancel: isMatrix
          ? authority?.canCancel ?? false
          : _cancelStatuses.contains(contract.statusCode) && !contract.isReturned,
      isReady: true,
      // Foydalanuvchi o'zi yakunlay olmasa sabab ko'rsatiladi.
      warning: isMatrix && !(canProceed || canAllow) ? authority?.message ?? '' : '',
    );
  }

  final ApproveAction approve;

  /// Birinchi tugma bosiladimi.
  final bool canApprove;

  final bool canEdit;
  final bool canCancel;

  /// Vakolat javobi keldimi. Eski dvijokda har doim `true`.
  final bool isReady;

  /// Amal mumkin emasligining sababi. Bo'sh bo'lsa ogohlantirish chiqmaydi.
  final String warning;

  static const Set<int> _approveStatuses = <int>{8, 9};
  static const Set<int> _editStatuses = <int>{1, 4, 5, 7, 8, 13};
  static const Set<int> _cancelStatuses = <int>{1, 3, 4, 5, 7, 8, 13};

  static bool _canEdit(ContractInfo contract) =>
      _editStatuses.contains(contract.statusCode) &&
      !contract.isReturned &&
      !contract.flex &&
      !contract.isSentForApproval;

  /// Shartnoma bosilganda nima ochilishi — statusga qarab.
  ///
  /// `10` (imzolangan) va `11` (tasdiqlangan) — faqat ko'rish. Ikkalasida ham
  /// tahrirlash mumkin emas (`_editStatuses` da yo'q), amal oynasini ochish
  /// esa foydalanuvchini «Batafsil» ni qidirishga majbur qilardi.
  static ContractTap tapOf(int statusCode) => switch (statusCode) {
    40 => ContractTap.selectIncome,
    24 || 25 => ContractTap.confirmSms,
    10 || 11 => ContractTap.viewProduct,
    _ => ContractTap.showActions,
  };

  /// Ruxsat berish va yuborish tasdiq so'raydi — ikkalasi ham qaytarilmaydi.
  bool get needsConfirmation => approve != ApproveAction.proceed;

  @override
  List<Object?> get props => [approve, canApprove, canEdit, canCancel, isReady, warning];
}
