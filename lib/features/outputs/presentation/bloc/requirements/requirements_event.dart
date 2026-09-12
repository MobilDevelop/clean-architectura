part of 'requirements_bloc.dart';

sealed class RequirementsEvent extends Equatable {
  const RequirementsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Ro'yxat o'qildi — ekran ochilganda va har bir yozuvdan qaytilganda.
final class RequirementsRequested extends RequirementsEvent {
  const RequirementsRequested();
}

final class FailureHandled extends RequirementsEvent {
  const FailureHandled();
}

final class Retried extends RequirementsEvent {
  const Retried();
}
