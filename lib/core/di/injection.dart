import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/di/app_startup.dart';
import 'package:colloborator_v3/core/network/dio_client.dart';
import 'package:colloborator_v3/core/network/interceptors/auth_interceptor.dart';
import 'package:colloborator_v3/core/network/interceptors/error_report_interceptor.dart';
import 'package:colloborator_v3/core/router/coordinator.dart';
import 'package:colloborator_v3/core/services/auth_notifier.dart';
import 'package:colloborator_v3/core/services/device_info_service.dart';
import 'package:colloborator_v3/core/services/error_reporter.dart';
import 'package:colloborator_v3/core/services/firebase_service.dart';
import 'package:colloborator_v3/core/services/push_token_service.dart';
import 'package:colloborator_v3/core/services/secure_token_storage.dart';
import 'package:colloborator_v3/core/services/telegram_error_reporter.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/auth/login/data/datasources/auth_remote_datasource.dart';
import 'package:colloborator_v3/features/auth/login/data/repositories/auth_repository_impl.dart';
import 'package:colloborator_v3/features/auth/login/domain/repositories/auth_repository.dart';
import 'package:colloborator_v3/features/auth/login/domain/usecase/login_usecase.dart';
import 'package:colloborator_v3/features/auth/login/presentation/bloc/login_bloc.dart';
import 'package:colloborator_v3/features/auth/registration/data/datasources/registration_remote_datasource.dart';
import 'package:colloborator_v3/features/auth/registration/data/repositories/registration_repository_impl.dart';
import 'package:colloborator_v3/features/auth/registration/domain/repositories/registration_repository.dart';
import 'package:colloborator_v3/features/auth/registration/domain/usecase/partners_usecase.dart';
import 'package:colloborator_v3/features/auth/registration/domain/usecase/registration_usecase.dart';
import 'package:colloborator_v3/features/auth/registration/presentation/bloc/registration_bloc.dart';
import 'package:colloborator_v3/features/contracts/data/datasources/contracts_remote_datasource.dart';
import 'package:colloborator_v3/features/contracts/data/repositories/contracts_repository_impl.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contracts_repository.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/contracts_usecase.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:colloborator_v3/features/customers/data/datasources/customer_remote_datasource.dart';
import 'package:colloborator_v3/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/customer_repository.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/check_client_usecase.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/customer_usecase.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/face_id_bloc.dart';
import 'package:colloborator_v3/features/invoices/presentation/bloc/invoices_bloc.dart';
import 'package:colloborator_v3/features/outputs/presentation/bloc/outputs_bloc.dart';
import 'package:colloborator_v3/features/splash/presentation/bloc/app_manager_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_alice/alice.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  _registerPlatform();
  _registerNetwork();
  _registerApp();
  _registerLogin();
  _registerRegistration();
  _registerSplash();
  _registerCustomer();
  _registerContracts();
  _registerOutputs();
  _registerInvoices();

  // Parse nosozliklari ham shu kanaldan ketadi.
  JsonParser.reporter = (issue) => getIt<ErrorReporter>().report(ErrorReport(source: issue.model, message: issue.reason, trace: issue.trace));
}

/// Platformaga va tashqi xizmatlarga ulanish nuqtalari
void _registerPlatform() {
  getIt
    ..registerLazySingleton(() => FirebaseService(getIt()))
    ..registerLazySingleton(() => FirebaseMessaging.instance)
    ..registerLazySingleton(() => PushTokenService(getIt()))
    ..registerLazySingleton(() => SecureTokenStorage(const FlutterSecureStorage(aOptions: AndroidOptions(),iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device))))
    ..registerLazySingleton<ErrorReporter>(() => TelegramErrorReporter(dio: Dio(),token: dotenv.env['BOT_TOKEN'] ?? '',chatId: dotenv.env['BOT_CHAT_ID'] ?? '',environment: AppConstants.isStaging ? 'staging' : 'production', now: DateTime.now))
    ..registerLazySingleton(() => DeviceInfoService(const MethodChannel('colloborator_v3/device')))
    ..registerLazySingleton(() => Alice(navigatorKey: CustomAnimatedToast.navigatorKey));
}

/// Tarmoq: yagona Dio va uning interceptorlari
void _registerNetwork() {
  getIt.registerLazySingleton<Dio>(
    () => createDio(
      interceptors: [
        AuthInterceptor(getIt()),
        if (AppConstants.isStaging) getIt<Alice>().getDioInterceptor(),

        // Oxirida: undan oldingilar hal qilgan xatolarni ko'rmasin.
        ErrorReportInterceptor(getIt()),
      ],
    ),
  );
}

/// Ilova darajasidagi holat va navigatsiya
void _registerApp() {
  getIt
    ..registerLazySingleton(() => AuthNotifier(getIt()))
    ..registerLazySingleton(() => AppRouter(getIt()))
    ..registerLazySingleton<AppStartup>(() => AppStartupImpl(getIt()));
}

/// features/auth/login — data → domain → presentation
void _registerLogin() {
  getIt
    ..registerLazySingleton(() => AuthRemoteDataSource(dio: getIt(), deviceInfo: getIt(),push: getIt()))
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()))
    ..registerLazySingleton(() => LoginUseCase(getIt()))
    ..registerFactory(() => LoginBloc(loginUseCase: getIt(), auth: getIt(), deviceInfo: getIt()));
}

/// features/auth/registration — data → domain → presentation
void _registerRegistration() {
  getIt
    ..registerLazySingleton(() => RegistrationRemoteDatasource(dio: getIt(), push: getIt(), deviceInfo: getIt()))
    ..registerLazySingleton<RegistrationRepository>(() => RegistrationRepositoryImpl(remote: getIt()))
    ..registerLazySingleton(() => PartnersUsecase(getIt()))
    ..registerLazySingleton(() => RegistrationUsecase(getIt()))
    ..registerFactory(() => RegistrationBloc(partnerUsecase: getIt(), registrationUsecase: getIt()));
}

void _registerCustomer() {
  getIt
    ..registerLazySingleton(() => CustomerRemoteDatasource(dio: getIt()))
    ..registerLazySingleton<CustomerRepository>(() => CustomerRepositoryImpl(remote: getIt()))
    ..registerLazySingleton(() => CustomerUsecase(getIt()))
    ..registerLazySingleton(() => CheckClientUsecase(getIt()))
    ..registerFactory(() => CustomersBloc(customerUsecase: getIt()))
    ..registerFactory(() => FaceIdBloc(checkClientUsecase: getIt(),now: DateTime.now));
}

/// features/splash
void _registerSplash() {
  getIt.registerFactory(() => AppManagerCubit(getIt()));
}

void _registerContracts() {
  getIt
  ..registerLazySingleton(() => ContractsRemoteDatasource(dio: getIt(),now: DateTime.now))
  ..registerLazySingleton<ContractRepository>(() => ContractsRepositoryImpl(remote: getIt()))
  ..registerLazySingleton(() => ContractsUsecase(getIt()))
  ..registerFactory(() => ContractsBloc(contractsUsecase: getIt()));
}

void _registerOutputs() {
  getIt.registerFactory(() => OutputsBloc());
}

void _registerInvoices() {
  getIt.registerFactory(() => InvoicesBloc());
}