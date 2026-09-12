part of 'contract_action_bloc.dart';

final class ContractActionState extends Equatable {
  const ContractActionState({
    required this.contract,
    required this.isLoading,
    required this.isDone,
    required this.isSigningRequested,
    this.authority,
    this.failure,
  });

  const ContractActionState.initial(this.contract)
    : isLoading = false,
      isDone = false,
      isSigningRequested = false,
      authority = null,
      failure = null;

  final ContractInfo contract;
  final bool isLoading;

  /// Amal bajarildi — oyna yopiladi va ro'yxat yangilanadi.
  final bool isDone;

  /// Imzolash sahifasi so'raldi. U hali yozilmagan, shuning uchun sahifa
  /// foydalanuvchiga holatni ochiq aytadi (5.8).
  final bool isSigningRequested;

  final ContractAuthority? authority;
  final Failure? failure;

  /// Qaysi tugma faol ekani — qoida domainda.
  ContractActions get actions => ContractActions.of(contract, authority: authority);

  ContractActionState copyWith({
    bool? isLoading,
    bool? isDone,
    bool? isSigningRequested,
    ContractAuthority? authority,
    Failure? failure,
    bool clearFailure = false,
  }) => ContractActionState(
    contract: contract,
    isLoading: isLoading ?? this.isLoading,
    isDone: isDone ?? this.isDone,
    isSigningRequested: isSigningRequested ?? this.isSigningRequested,
    authority: authority ?? this.authority,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [contract, isLoading, isDone, isSigningRequested, authority, failure];
}
