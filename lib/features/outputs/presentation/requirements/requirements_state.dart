part of 'requirements_bloc.dart';

final class RequirementsState extends Equatable {
  const RequirementsState({
    required this.contractId,
    required this.isLoading,
    required this.requirements,
    this.failure,
  });

  const RequirementsState.initial(this.contractId)
    : isLoading = false,
      requirements = null,
      failure = null;

  final int contractId;
  final bool isLoading;

  /// `null` — hali o'qilmagan. Bo'sh ro'yxatdan shu bilan ajraladi.
  final IcloudRequirements? requirements;

  final Failure? failure;

  List<IcloudDevice> get devices => requirements?.devices ?? const <IcloudDevice>[];

  bool get isEmpty => requirements != null && devices.isEmpty;

  RequirementsState copyWith({
    bool? isLoading,
    IcloudRequirements? requirements,
    Failure? failure,
    bool clearFailure = false,
  }) => RequirementsState(
    contractId: contractId,
    isLoading: isLoading ?? this.isLoading,
    requirements: requirements ?? this.requirements,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[contractId, isLoading, requirements, failure];
}
