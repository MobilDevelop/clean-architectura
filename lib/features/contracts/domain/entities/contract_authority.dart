import 'package:equatable/equatable.dart';

/// Shartnoma amallarini kim hal qiladi.
///
/// `matrix` — "Vakolat 2.0": server har bir amal uchun ruxsatni o'zi aytadi.
/// `legacy` — eski dvijok: amallar shartnomaning statusi va bayroqlaridan
/// hisoblanadi. Backend `authority_engine` maydonida yuboradi.
enum AuthorityEngine { matrix, legacy }

/// `contract-authority/check/{id}` javobi.
///
/// Uch bayroqdan har bir lahzada faqat bittasi `true` bo'ladi. Uchalasi ham
/// `false` bo'lsa — amal yo'q va sababi [message] da keladi.
final class ContractAuthority extends Equatable {
  const ContractAuthority({
    required this.message,
    required this.canProceed,
    required this.canApprove,
    required this.canEscalate,
    required this.canCancel,
  });

  /// Amal yo'qligining sababi. Bo'sh bo'lishi mumkin.
  final String message;

  /// Oqim davom etadi — imzolash sahifasi ochiladi, so'rov yuborilmaydi.
  final bool canProceed;

  /// O'ziga eskalatsiya qilingan shartnomaga ruxsat berish.
  final bool canApprove;

  /// Vakolat yetmaydi — shartnomani kerakli darajaga yo'naltirish.
  final bool canEscalate;

  final bool canCancel;

  @override
  List<Object?> get props => [message, canProceed, canApprove, canEscalate, canCancel];
}
