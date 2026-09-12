part of 'underwriter_bloc.dart';

sealed class UnderwriterEvent extends Equatable {
  const UnderwriterEvent();

  @override
  List<Object?> get props => [];
}

/// Ekran ochildi: ma'lumotnomalar va saqlangan holat yuklanadi.
final class UnderwriterRequested extends UnderwriterEvent {
  const UnderwriterRequested();
}

final class SectionSelected extends UnderwriterEvent {
  const SectionSelected(this.kind);

  final UnderwriterKind kind;

  @override
  List<Object?> get props => [kind];
}

/// Sahifa fayl tanladi. Tanlash oynasi UI ta'siri — u bloc ichida ochilmaydi (6.2).
final class FileAdded extends UnderwriterEvent {
  const FileAdded({required this.file, required this.bytes, required this.extension});

  final File file;
  final int bytes;
  final String extension;

  @override
  List<Object?> get props => [file.path, bytes, extension];
}

final class FileRemoved extends UnderwriterEvent {
  const FileRemoved(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class SalaryAmountChanged extends UnderwriterEvent {
  const SalaryAmountChanged({required this.index, required this.amount});

  final int index;
  final int amount;

  @override
  List<Object?> get props => [index, amount];
}

final class PensionAmountChanged extends UnderwriterEvent {
  const PensionAmountChanged(this.amount);

  final int amount;

  @override
  List<Object?> get props => [amount];
}

final class PositionSelected extends UnderwriterEvent {
  const PositionSelected(this.position);

  final MilitaryPosition position;

  @override
  List<Object?> get props => [position];
}

final class CarBrandSelected extends UnderwriterEvent {
  const CarBrandSelected(this.brand);

  final UnderwriterOption brand;

  @override
  List<Object?> get props => [brand];
}

final class CarModelSelected extends UnderwriterEvent {
  const CarModelSelected(this.model);

  final UnderwriterOption model;

  @override
  List<Object?> get props => [model];
}

final class CarYearSelected extends UnderwriterEvent {
  const CarYearSelected(this.year);

  final int year;

  @override
  List<Object?> get props => [year];
}

final class SectionSubmitted extends UnderwriterEvent {
  const SectionSubmitted();
}

final class FailureHandled extends UnderwriterEvent {
  const FailureHandled();
}

final class Retried extends UnderwriterEvent {
  const Retried();
}
