part of 'invoices_bloc.dart';

sealed class InvoicesEvent extends Equatable {
  const InvoicesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Birinchi sahifa so'raldi (ekran ochilganda va tortib yangilashda).
final class InvoicesRequested extends InvoicesEvent {
  const InvoicesRequested();
}

/// Ro'yxat oxiriga yetildi — keyingi sahifa.
final class NextPageRequested extends InvoicesEvent {
  const NextPageRequested();
}

/// Sana filtri tanlandi.
final class DateSelected extends InvoicesEvent {
  const DateSelected(this.date);

  final DateTime date;

  @override
  List<Object?> get props => <Object?>[date];
}

/// Sana filtri tozalandi.
final class DateCleared extends InvoicesEvent {
  const DateCleared();
}

/// Yuk xati ta'minotchiga yuborildi.
final class SendRequested extends InvoicesEvent {
  const SendRequested(this.invoice);

  final Invoice invoice;

  @override
  List<Object?> get props => <Object?>[invoice];
}

final class FailureHandled extends InvoicesEvent {
  const FailureHandled();
}

/// Yiqilgan amalni takrorlaydi.
final class Retried extends InvoicesEvent {
  const Retried();
}
