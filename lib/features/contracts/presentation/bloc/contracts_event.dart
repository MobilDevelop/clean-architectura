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
