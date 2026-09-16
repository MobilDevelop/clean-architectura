part of 'guarantor_instruments_bloc.dart';

sealed class InstrumentsEvent {
  const InstrumentsEvent();
}

final class InstrumentsStarted extends InstrumentsEvent {
  const InstrumentsStarted();
}

final class InstrumentToggled extends InstrumentsEvent {
  const InstrumentToggled(this.type);

  final InstrumentType type;
}

final class InstrumentCardChanged extends InstrumentsEvent {
  const InstrumentCardChanged({this.number, this.expiry, this.phone});

  final String? number;
  final String? expiry;
  final String? phone;
}

final class InstrumentsSubmitted extends InstrumentsEvent {
  const InstrumentsSubmitted();
}

final class InstrumentsFailureHandled extends InstrumentsEvent {
  const InstrumentsFailureHandled();
}

final class InstrumentsRetried extends InstrumentsEvent {
  const InstrumentsRetried();
}
