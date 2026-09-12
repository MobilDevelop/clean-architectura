part of 'contract_guarantors_bloc.dart';

sealed class ContractGuarantorsEvent extends Equatable {
  const ContractGuarantorsEvent();

  @override
  List<Object?> get props => [];
}

/// Mijozlar ekrani kafilni qaytardi. Faqat oddiy tiplar — feature featureni
/// import qilmaydi (1.3).
final class GuarantorAdded extends ContractGuarantorsEvent {
  const GuarantorAdded({required this.clientId, required this.fullName, required this.passport});

  final int clientId;
  final String fullName;
  final String passport;

  @override
  List<Object?> get props => [clientId, fullName, passport];
}

final class GuarantorRemoved extends ContractGuarantorsEvent {
  const GuarantorRemoved(this.rowId);

  final int rowId;

  @override
  List<Object?> get props => [rowId];
}

final class FailureHandled extends ContractGuarantorsEvent {
  const FailureHandled();
}

final class Retried extends ContractGuarantorsEvent {
  const Retried();
}
