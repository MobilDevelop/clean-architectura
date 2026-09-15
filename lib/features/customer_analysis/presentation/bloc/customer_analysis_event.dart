part of 'customer_analysis_bloc.dart';

sealed class CustomerAnalysisEvent extends Equatable {
  const CustomerAnalysisEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Ro'yxat so'raldi (ekran ochilganda va tortib yangilashda).
final class AnalysisRequested extends CustomerAnalysisEvent {
  const AnalysisRequested();
}

/// Yangi tahlil so'rovi yuborildi.
final class AnalysisSubmitted extends CustomerAnalysisEvent {
  const AnalysisSubmitted({
    required this.inps,
    required this.contactPhone,
    required this.isAdvanced,
    required this.card,
  });

  final String inps;
  final String contactPhone;
  final bool isAdvanced;
  final AnalysisCardEntry card;

  @override
  List<Object?> get props => <Object?>[inps, contactPhone, isAdvanced, card];
}

/// SMS kodi kiritilib tasdiqlash bosildi.
final class SmsConfirmSubmitted extends CustomerAnalysisEvent {
  const SmsConfirmSubmitted({required this.item, required this.code});

  final CustomerAnalysis item;
  final String code;

  @override
  List<Object?> get props => <Object?>[item, code];
}

/// Muvaffaqiyatli yuborish xabari ko'rsatildi — bir martalik bayroq
/// tozalanadi.
final class SubmittedShown extends CustomerAnalysisEvent {
  const SubmittedShown();
}

/// Tasdiqlangan yozuv oynasi yopildi — bir martalik bayroq tozalanadi.
final class ConfirmedShown extends CustomerAnalysisEvent {
  const ConfirmedShown();
}

final class FailureHandled extends CustomerAnalysisEvent {
  const FailureHandled();
}

/// Yiqilgan amalni takrorlaydi.
final class Retried extends CustomerAnalysisEvent {
  const Retried();
}
