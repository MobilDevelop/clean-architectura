part of 'app_manager_cubit.dart';

sealed class AppManagerState {
  const AppManagerState();
}

final class AppManagerInitial extends AppManagerState {
  const AppManagerInitial();
}

final class AppManagerLoading extends AppManagerState {}

final class AppManagerError extends AppManagerState {
  const AppManagerError(this.failure);

  final Failure failure;
}
