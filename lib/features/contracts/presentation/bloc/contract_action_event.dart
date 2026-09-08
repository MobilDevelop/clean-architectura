part of 'contract_action_bloc.dart';

sealed class ContractActionEvent extends Equatable {
  const ContractActionEvent();

  @override
  List<Object> get props => [];
}

/// Oyna ochildi: matritsa dvijogida vakolat so'raladi.
final class ActionsRequested extends ContractActionEvent {
  const ActionsRequested();
}

final class ApprovePressed extends ContractActionEvent {
  const ApprovePressed();
}

/// Bekor qilish tasdiqlangandan keyin. Tasdiqni sahifa so'raydi (6.2).
final class CancelConfirmed extends ContractActionEvent {
  const CancelConfirmed();
}

final class FailureHandled extends ContractActionEvent {
  const FailureHandled();
}
