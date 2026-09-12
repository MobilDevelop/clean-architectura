part of 'outputs_bloc.dart';

sealed class OutputsEvent extends Equatable {
  const OutputsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Birinchi sahifa so'raldi (ekran ochilganda va tortib yangilashda).
final class OutputsRequested extends OutputsEvent {
  const OutputsRequested();
}

/// Ro'yxat oxiriga yetildi — keyingi sahifa.
final class NextPageRequested extends OutputsEvent {
  const NextPageRequested();
}

/// Sana filtri tanlandi.
final class DateSelected extends OutputsEvent {
  const DateSelected(this.date);

  final DateTime date;

  @override
  List<Object?> get props => <Object?>[date];
}

/// Sana filtri tozalandi.
final class DateCleared extends OutputsEvent {
  const DateCleared();
}

/// Qator ochildi yoki yopildi. Tovarlar birinchi ochilganda o'qiladi.
final class ContractToggled extends OutputsEvent {
  const ContractToggled(this.contractId);

  final int contractId;

  @override
  List<Object?> get props => <Object?>[contractId];
}

/// Qaytarish uchun tovar belgilandi yoki belgi olindi.
final class ProductToggled extends OutputsEvent {
  const ProductToggled(this.productId);

  final int productId;

  @override
  List<Object?> get props => <Object?>[productId];
}

/// Belgilangan tovarlar qaytarildi.
final class ReturnRequested extends OutputsEvent {
  const ReturnRequested();
}

final class FailureHandled extends OutputsEvent {
  const FailureHandled();
}

/// Yiqilgan amalni takrorlaydi.
final class Retried extends OutputsEvent {
  const Retried();
}
