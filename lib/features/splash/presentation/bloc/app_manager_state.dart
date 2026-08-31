part of 'app_manager_cubit.dart';

sealed class AppManagerState {
  const AppManagerState();
}

final class AppManagerInitial extends AppManagerState {
  final String version;
  const AppManagerInitial({required this.version});
}

final class AppManagerLoading extends AppManagerState {}

final class AppManagerError extends AppManagerState {
  const AppManagerError(this.failure);

  final Failure failure;
}
