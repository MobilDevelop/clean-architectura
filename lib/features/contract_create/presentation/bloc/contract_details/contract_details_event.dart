part of 'contract_details_bloc.dart';

sealed class ContractDetailsEvent extends Equatable {
  const ContractDetailsEvent();

  @override
  List<Object> get props => [];
}

final class DetailsRequested extends ContractDetailsEvent {
  const DetailsRequested();
}

/// Shartnoma faylini ulashish so'raldi.
final class FileShareRequested extends ContractDetailsEvent {
  const FileShareRequested();
}

/// Ulashish oynasi ochildi — fayl holatdan olib tashlanadi.
///
/// Nega kerak: aks holda ekran qayta qurilganda oyna ikkinchi marta ochilardi.
final class FileShared extends ContractDetailsEvent {
  const FileShared();
}

final class FailureHandled extends ContractDetailsEvent {
  const FailureHandled();
}
