part of 'app_manager_cubit.dart';

sealed class AppManagerState {
  const AppManagerState();
}

final class AppManagerInitial extends AppManagerState {
  final String version;
  AppManagerInitial({required this.version});
}

final class AppManagerLoading extends AppManagerState {}

final class AppManagerError extends AppManagerState {
  AppManagerError(this.error);

  final String error;
}
