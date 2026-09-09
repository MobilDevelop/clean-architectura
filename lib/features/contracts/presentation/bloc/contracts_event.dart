import 'package:colloborator_v3/core/contract/contract_changes.dart';
import 'package:equatable/equatable.dart';

sealed class ContractsEvent extends Equatable{

 const ContractsEvent();

 @override
  List<Object?> get props => [];
}

final class ContractsGet extends ContractsEvent{
  const ContractsGet();
}

final class DateSelected extends ContractsEvent{
  const DateSelected({required this.date});

  final DateTime date;
}

final class FailureHandled extends ContractsEvent {
  const FailureHandled();
}

final class DateCleared extends ContractsEvent {
  const DateCleared();
}

/// Boshqa ekranda shartnoma yozildi — ro'yxat eskirdi.
final class ContractsStale extends ContractsEvent {
  const ContractsStale(this.change);

  final ContractChange change;

  @override
  List<Object?> get props => <Object?>[change];
}

/// Push xabari keldi — ro'yxat eskirdi.
final class PushReceived extends ContractsEvent {
  const PushReceived();
}

/// Bildirishnoma bosildi. Qaysi shartnoma ekanini bloc `PushNotifications`
/// dan oladi: xabar bir marta ishlatilishi kerak.
final class PushOpened extends ContractsEvent {
  const PushOpened();
}

/// Kutilayotgan shartnoma ochildi (yoki topilmadi) — belgi tozalanadi.
final class ContractOpened extends ContractsEvent {
  const ContractOpened();
}
