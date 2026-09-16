part of 'contract_guarantors_bloc.dart';

sealed class ContractGuarantorsEvent extends Equatable {
  const ContractGuarantorsEvent();

  @override
  List<Object?> get props => [];
}

/// Mijozlar ekrani kafilni qaytardi. Faqat oddiy tiplar — feature featureni
/// import qilmaydi (1.3).
final class GuarantorAdded extends ContractGuarantorsEvent {
  const GuarantorAdded({
    required this.clientId,
    required this.fullName,
    required this.passport,
    required this.inps,
    required this.workplaceCategoryId,
  });

  final int clientId;
  final String fullName;
  final String passport;
  final String inps;
  final int workplaceCategoryId;

  @override
  List<Object?> get props => [clientId, fullName, passport];
}

final class GuarantorRemoved extends ContractGuarantorsEvent {
  const GuarantorRemoved(this.rowId);

  final int rowId;

  @override
  List<Object?> get props => [rowId];
}

/// Shartnoma qayta o'qildi — kafillar ro'yxati serverdagi holatga
/// keltiriladi. Busiz anderrayter yoki instrument saqlangandan keyin karta
/// eski ma'lumotni ko'rsatib turardi: bloc o'z nusxasini bir marta olib,
/// keyin faqat o'zining qo'shish/o'chirishidan o'zgartirardi.
final class GuarantorsSynced extends ContractGuarantorsEvent {
  const GuarantorsSynced(this.guarantors);

  final List<ContractGuarantor> guarantors;

  @override
  List<Object?> get props => [guarantors];
}

final class FailureHandled extends ContractGuarantorsEvent {
  const FailureHandled();
}

final class Retried extends ContractGuarantorsEvent {
  const Retried();
}
