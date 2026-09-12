part of 'contract_details_bloc.dart';

final class ContractDetailsState extends Equatable {
  const ContractDetailsState({
    required this.isLoading,
    required this.isFileLoading,
    this.details,
    this.shareFile,
    this.failure,
  });

  const ContractDetailsState.initial()
    : isLoading = false,
      isFileLoading = false,
      details = null,
      shareFile = null,
      failure = null;

  final bool isLoading;

  /// Fayl yuklab olinmoqda.
  final bool isFileLoading;

  final ContractDetails? details;

  /// Ulashishga tayyor fayl. `null` — ulashadigan narsa yo'q.
  ///
  /// Nega state'da: ulashish oynasi UI ta'siri, uni bloc ochmaydi (6.2).
  /// Bloc faqat faylni tayyorlaydi, oynani sahifa ochadi.
  final File? shareFile;

  final Failure? failure;

  ContractDetailsState copyWith({
    bool? isLoading,
    bool? isFileLoading,
    ContractDetails? details,
    File? shareFile,
    bool clearShareFile = false,
    Failure? failure,
    bool clearFailure = false,
  }) => ContractDetailsState(
    isLoading: isLoading ?? this.isLoading,
    isFileLoading: isFileLoading ?? this.isFileLoading,
    details: details ?? this.details,
    shareFile: clearShareFile ? null : shareFile ?? this.shareFile,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [isLoading, isFileLoading, details, shareFile?.path, failure];
}
