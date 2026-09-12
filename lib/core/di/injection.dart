import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/di/app_startup.dart';
import 'package:colloborator_v3/core/network/dio_client.dart';
import 'package:colloborator_v3/core/network/interceptors/auth_interceptor.dart';
import 'package:colloborator_v3/core/network/interceptors/error_report_interceptor.dart';
import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/router/coordinator.dart';
import 'package:colloborator_v3/core/services/auth_notifier.dart';
import 'package:colloborator_v3/core/services/device_info_service.dart';
import 'package:colloborator_v3/core/services/error_reporter.dart';
import 'package:colloborator_v3/core/services/firebase_service.dart';
import 'package:colloborator_v3/core/services/push_token_service.dart';
import 'package:colloborator_v3/core/contract/contract_changes.dart';
import 'package:colloborator_v3/core/services/app_info.dart';
import 'package:colloborator_v3/core/services/offer_document.dart';
import 'package:colloborator_v3/core/services/push_notifications.dart';
import 'package:colloborator_v3/core/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:colloborator_v3/core/services/local_cache.dart';
import 'package:colloborator_v3/core/session/session_store.dart';
import 'package:colloborator_v3/core/services/secure_token_storage.dart';
import 'package:colloborator_v3/core/services/shared_prefs_cache.dart';
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
import 'package:colloborator_v3/features/contracts/domain/usecase/get_contract_scoring_usecase.dart';
import 'package:colloborator_v3/features/contracts/data/datasources/contract_signing_remote_datasource.dart';
import 'package:colloborator_v3/features/contracts/data/datasources/card_confirm_remote_datasource.dart';
import 'package:colloborator_v3/features/contracts/data/repositories/card_confirm_repository_impl.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/card_confirm_repository.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/card_confirm_usecases.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/card_confirm_bloc.dart';
import 'package:colloborator_v3/features/contracts/data/repositories/contract_signing_repository_impl.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_signing.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contract_signing_repository.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/signing_usecases.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_signing_bloc.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/get_flex_messages_usecase.dart';
import 'package:colloborator_v3/features/underwriter/data/datasources/underwriter_remote_datasource.dart';
import 'package:colloborator_v3/features/underwriter/data/repositories/underwriter_repository_impl.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_data.dart';
import 'package:colloborator_v3/features/underwriter/domain/repositories/underwriter_repository.dart';
import 'package:colloborator_v3/features/underwriter/domain/usecase/underwriter_usecases.dart';
import 'package:colloborator_v3/features/underwriter/presentation/bloc/underwriter_bloc.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/contract_create_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/contract_file_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/repositories/contract_file_repository_impl.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_file_repository.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/download_contract_file_usecase.dart';
import 'package:colloborator_v3/features/contract_create/data/repositories/contract_create_repository_impl.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_create_repository.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/add_product_usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_form.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/catalog_usecases.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/contract_write_usecases.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/get_contract_details_usecase.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/contract_guarantor_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/contract_income_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/katm_skip_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/manager_bonus_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/payment_schedule_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/special_tariff_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/repositories/contract_guarantor_repository_impl.dart';
import 'package:colloborator_v3/features/contract_create/data/repositories/contract_income_repository_impl.dart';
import 'package:colloborator_v3/features/contract_create/data/repositories/katm_skip_repository_impl.dart';
import 'package:colloborator_v3/features/contract_create/data/repositories/manager_bonus_repository_impl.dart';
import 'package:colloborator_v3/features/contract_create/data/repositories/payment_schedule_repository_impl.dart';
import 'package:colloborator_v3/features/contract_create/data/repositories/special_tariff_repository_impl.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/payment_schedule.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_guarantor_repository.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_income_repository.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/katm_skip_repository.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/manager_bonus_repository.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/payment_schedule_repository.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/special_tariff_repository.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/guarantor_usecases.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/income_usecases.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/katm_skip_usecases.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/manager_bonus_usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/payment_schedule_usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/special_tariff_usecases.dart';
import 'package:colloborator_v3/features/contract_create/presentation/guarantors/contract_guarantors_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_create_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/income/contract_card_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/products/contract_products_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/katm_skip/katm_skip_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bonus/manager_bonus_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/schedule/payment_schedule_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/tariff/special_tariff_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/details/contract_details_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/picker/product_picker_bloc.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/contract_authority_usecases.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/get_katm_usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/get_mib_usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/get_participants_usecase.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_action_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_result_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:colloborator_v3/features/customers/data/datasources/customer_remote_datasource.dart';
import 'package:colloborator_v3/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/customer_repository.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/check_client_usecase.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/customer_usecase.dart';
import 'package:colloborator_v3/features/customers/data/datasources/address_local_datasource.dart';
import 'package:colloborator_v3/features/customers/data/datasources/address_remote_datasource.dart';
import 'package:colloborator_v3/features/customers/data/datasources/workplace_remote_datasource.dart';
import 'package:colloborator_v3/features/customers/data/repositories/address_repository_impl.dart';
import 'package:colloborator_v3/features/customers/data/repositories/workplace_repository_impl.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/address_repository.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/workplace_repository.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/get_provinces_usecase.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/get_regions_usecase.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/get_villages_usecase.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/get_scoring_usecase.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/search_workplaces_usecase.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/update_customer_usecase.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/add_customer_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/scoring_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/face_id_bloc.dart';
import 'package:colloborator_v3/features/invoices/presentation/bloc/invoices_bloc.dart';
import 'package:colloborator_v3/features/outputs/data/datasources/outputs_remote_datasource.dart';
import 'package:colloborator_v3/features/outputs/data/repositories/outputs_repository_impl.dart';
import 'package:colloborator_v3/features/outputs/domain/repositories/outputs_repository.dart';
import 'package:colloborator_v3/features/outputs/domain/usecase/outputs_usecases.dart';
import 'package:colloborator_v3/features/outputs/data/datasources/icloud_remote_datasource.dart';
import 'package:colloborator_v3/features/outputs/data/datasources/output_release_remote_datasource.dart';
import 'package:colloborator_v3/features/outputs/data/repositories/icloud_repository_impl.dart';
import 'package:colloborator_v3/features/outputs/data/repositories/output_release_repository_impl.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';
import 'package:colloborator_v3/features/outputs/domain/repositories/icloud_repository.dart';
import 'package:colloborator_v3/features/outputs/domain/repositories/output_release_repository.dart';
import 'package:colloborator_v3/features/outputs/domain/usecase/icloud_usecases.dart';
import 'package:colloborator_v3/features/outputs/domain/usecase/release_usecases.dart';
import 'package:colloborator_v3/features/outputs/presentation/credential/credential_bloc.dart';
import 'package:colloborator_v3/features/outputs/presentation/list/outputs_bloc.dart';
import 'package:colloborator_v3/features/outputs/presentation/release/release_bloc.dart';
import 'package:colloborator_v3/features/outputs/presentation/requirements/requirements_bloc.dart';
import 'package:colloborator_v3/features/splash/presentation/bloc/app_manager_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_alice/alice.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies(SharedPreferences prefs) {
  _registerPlatform(prefs);
  _registerNetwork();
  _registerApp();
  _registerLogin();
  _registerRegistration();
  _registerSplash();
  _registerCustomer();
  _registerContracts();
  _registerContractCreate();
  _registerUnderwriter();
  _registerOutputs();
  _registerInvoices();

  // Parse nosozliklari ham shu kanaldan ketadi.
  JsonParser.reporter = (issue) => getIt<ErrorReporter>().report(ErrorReport(source: issue.model, message: issue.reason, trace: issue.trace));

  // Repository chegarasida `Failure` ga o'girilgan istisnolar ham (5.7).
  // Ular `ErrorReportInterceptor` dan o'tmaydi: interceptor faqat zanjir
  // ichidagi `DioException` ni ko'radi.
  GuardReport.reporter = (failure, error, trace) =>
      getIt<ErrorReporter>().report(ErrorReport(source: failure.runtimeType.toString(), message: '$error', trace: trace));
}

/// Platformaga va tashqi xizmatlarga ulanish nuqtalari
void _registerPlatform(SharedPreferences prefs) {
  getIt
    ..registerLazySingleton(PushNotifications.new)
    ..registerLazySingleton(ContractChanges.new)
    ..registerLazySingleton(AppInfo.new)
    ..registerLazySingleton(() => OfferDocument(rootBundle))
    ..registerLazySingleton(FlutterLocalNotificationsPlugin.new)
    ..registerLazySingleton(() => LocalNotificationService(plugin: getIt(), push: getIt()))
    ..registerLazySingleton(() => FirebaseService(getIt(), getIt(), getIt()))
    ..registerLazySingleton(() => FirebaseMessaging.instance)
    ..registerLazySingleton(() => PushTokenService(getIt()))
    ..registerLazySingleton<SessionStore>(MemorySessionStore.new)
    ..registerLazySingleton<LocalCache>(() => SharedPrefsCache(prefs: prefs, now: DateTime.now))
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
    ..registerLazySingleton(() => AuthNotifier(getIt(), getIt(), getIt()))
    ..registerLazySingleton(() => AppRouter(getIt(), getIt()))
    ..registerLazySingleton<AppStartup>(() => AppStartupImpl(getIt(), getIt(), getIt()));
}

/// features/auth/login — data → domain → presentation
void _registerLogin() {
  getIt
    ..registerLazySingleton(() => AuthRemoteDataSource(dio: getIt(), deviceInfo: getIt(),push: getIt()))
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()))
    ..registerLazySingleton(() => LoginUseCase(getIt()))
    ..registerFactory(() => LoginBloc(loginUseCase: getIt(), auth: getIt(), session: getIt(), deviceInfo: getIt()));
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
    ..registerFactory(() => FaceIdBloc(checkClientUsecase: getIt(), now: DateTime.now))
    ..registerLazySingleton(() => AddressRemoteDatasource(dio: getIt()))
    ..registerLazySingleton(() => AddressLocalDatasource(cache: getIt()))
    ..registerLazySingleton<AddressRepository>(() => AddressRepositoryImpl(remote: getIt(), local: getIt()))
    ..registerLazySingleton(() => WorkplaceRemoteDatasource(dio: getIt()))
    ..registerLazySingleton<WorkplaceRepository>(() => WorkplaceRepositoryImpl(remote: getIt()))
    ..registerLazySingleton(() => GetProvincesUsecase(getIt()))
    ..registerLazySingleton(() => GetRegionsUsecase(getIt()))
    ..registerLazySingleton(() => GetVillagesUsecase(getIt()))
    ..registerLazySingleton(() => SearchWorkplacesUsecase(getIt()))
    ..registerLazySingleton(() => UpdateCustomerUsecase(getIt()))
    ..registerLazySingleton(() => GetScoringUsecase(getIt()))
    ..registerFactory(() => ScoringBloc(getScoring: getIt()))
    // Mijoz va rejim ekran ochilganda ma'lum bo'ladi — shuning uchun parametrli.
    ..registerFactoryParam<AddCustomerBloc, CustomerInfo, bool>(
      (CustomerInfo info, bool? isEdit) => AddCustomerBloc(
        info: info,
        isEdit: isEdit ?? false,
        getProvinces: getIt(),
        getRegions: getIt(),
        getVillages: getIt(),
        searchWorkplaces: getIt(),
        updateCustomer: getIt(),
      ),
    );
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
  ..registerFactory(() => ContractsBloc(contractsUsecase: getIt(), push: getIt(), changes: getIt()))
  ..registerLazySingleton(() => CardConfirmRemoteDatasource(dio: getIt()))
  ..registerLazySingleton<CardConfirmRepository>(() => CardConfirmRepositoryImpl(remote: getIt()))
  ..registerLazySingleton(() => GetCardConfirmationUsecase(getIt()))
  ..registerLazySingleton(() => SubmitCardConfirmationUsecase(getIt()))
  ..registerFactoryParam<CardConfirmBloc, int, void>(
    (int contractId, void _) =>
        CardConfirmBloc(contractId: contractId, get: getIt(), submit: getIt(), changes: getIt()),
  )
  ..registerLazySingleton(() => ContractSigningRemoteDatasource(dio: getIt()))
  ..registerLazySingleton<ContractSigningRepository>(() => ContractSigningRepositoryImpl(remote: getIt()))
  ..registerLazySingleton(() => GetContractFileUsecase(getIt()))
  ..registerLazySingleton(() => ConfirmParticipantFaceUsecase(getIt()))
  ..registerLazySingleton(() => SignContractUsecase(getIt()))
  ..registerFactoryParam<ContractSigningBloc, ContractSigning, void>(
    (ContractSigning signing, void _) => ContractSigningBloc(
      signing: signing,
      getFile: getIt(),
      confirmFace: getIt(),
      sign: getIt(),
      changes: getIt(),
    ),
  )
  ..registerLazySingleton(() => GetContractScoringUsecase(getIt()))
  ..registerLazySingleton(() => GetFlexMessagesUsecase(getIt()))
  ..registerLazySingleton(() => GetParticipantsUsecase(getIt()))
  ..registerLazySingleton(() => GetMibUsecase(getIt()))
  ..registerLazySingleton(() => GetKatmUsecase(getIt()))
  ..registerLazySingleton(() => GetAuthorityUsecase(getIt()))
  ..registerLazySingleton(() => ConfirmAuthorityUsecase(getIt()))
  ..registerLazySingleton(() => EscalateAuthorityUsecase(getIt()))
  ..registerLazySingleton(() => AllowConfirmationUsecase(getIt()))
  ..registerLazySingleton(() => CancelContractUsecase(getIt()))
  // Shartnoma amal oynasi ochilganda ma'lum bo'ladi.
  ..registerFactoryParam<ContractActionBloc, ContractInfo, void>(
    (ContractInfo contract, void _) => ContractActionBloc(
      contract: contract,
      getAuthority: getIt(),
      confirmAuthority: getIt(),
      escalateAuthority: getIt(),
      allowConfirmation: getIt(),
      cancelContract: getIt(),
    ),
  )
  // Shartnoma va uning turi ekran ochilganda ma'lum bo'ladi.
  ..registerFactoryParam<ContractResultBloc, int, bool>(
    (int contractId, bool? isFlex) => ContractResultBloc(
      contractId: contractId,
      isFlex: isFlex ?? false,
      getScoring: getIt(),
      getFlexMessages: getIt(),
      getParticipants: getIt(),
      getMib: getIt(),
      getKatm: getIt(),
    ),
  );
}

/// Shartnoma tuzish featurei: ko'rish, tovar tanlash va tuzish ekranlari.
void _registerContractCreate() {
  getIt
    // Datasource — har bir resurs oilasi uchun bittadan (4.1).
    ..registerLazySingleton(() => ContractCreateRemoteDatasource(dio: getIt()))
    ..registerLazySingleton(() => ContractIncomeRemoteDatasource(dio: getIt()))
    ..registerLazySingleton(() => ContractGuarantorRemoteDatasource(dio: getIt()))
    ..registerLazySingleton(() => PaymentScheduleRemoteDatasource(dio: getIt()))
    ..registerLazySingleton(() => SpecialTariffRemoteDatasource(dio: getIt()))
    ..registerLazySingleton(() => ManagerBonusRemoteDatasource(dio: getIt()))
    ..registerLazySingleton(() => KatmSkipRemoteDatasource(dio: getIt()))
    // Repository — shartnoma har bir iste'molchi uchun alohida (ISP).
    ..registerLazySingleton<ContractCreateRepository>(() => ContractCreateRepositoryImpl(remote: getIt()))
    ..registerLazySingleton<ContractIncomeRepository>(() => ContractIncomeRepositoryImpl(remote: getIt()))
    ..registerLazySingleton<ContractGuarantorRepository>(
      () => ContractGuarantorRepositoryImpl(remote: getIt()),
    )
    ..registerLazySingleton<PaymentScheduleRepository>(() => PaymentScheduleRepositoryImpl(remote: getIt()))
    ..registerLazySingleton<SpecialTariffRepository>(() => SpecialTariffRepositoryImpl(remote: getIt()))
    ..registerLazySingleton<ManagerBonusRepository>(() => ManagerBonusRepositoryImpl(remote: getIt()))
    ..registerLazySingleton<KatmSkipRepository>(() => KatmSkipRepositoryImpl(remote: getIt()))
    // Usecase
    ..registerLazySingleton(() => GetContractDetailsUsecase(getIt()))
    ..registerLazySingleton(() => GetSuppliersUsecase(getIt()))
    ..registerLazySingleton(() => GetCategoriesUsecase(getIt()))
    ..registerLazySingleton(() => GetBrandsUsecase(getIt()))
    ..registerLazySingleton(() => GetVariantsUsecase(getIt()))
    ..registerLazySingleton(() => CreateDraftUsecase(getIt()))
    ..registerLazySingleton(() => AddProductUsecase(getIt(), getIt()))
    ..registerLazySingleton(() => ScanImeiUsecase(getIt()))
    ..registerLazySingleton(() => UpdateProductUsecase(getIt()))
    ..registerLazySingleton(() => DeleteProductUsecase(getIt(), getIt()))
    ..registerLazySingleton(() => GetPaymentDaysUsecase(getIt()))
    ..registerLazySingleton(() => SubmitContractUsecase(getIt()))
    ..registerLazySingleton(() => GetOccupationsUsecase(getIt()))
    ..registerLazySingleton(() => AddCardUsecase(getIt()))
    ..registerLazySingleton(() => RemoveCardUsecase(getIt()))
    ..registerLazySingleton(() => AddGuarantorUsecase(getIt()))
    ..registerLazySingleton(() => RemoveGuarantorUsecase(getIt()))
    ..registerLazySingleton(() => GetScheduleUsecase(getIt()))
    ..registerLazySingleton(() => GetAvailableTariffsUsecase(getIt()))
    ..registerLazySingleton(() => ApplyTariffUsecase(getIt()))
    ..registerLazySingleton(() => RemoveTariffUsecase(getIt()))
    ..registerLazySingleton(() => GetAppliedTariffUsecase(getIt()))
    ..registerLazySingleton(() => SendBonusUsecase(getIt()))
    ..registerLazySingleton(() => GetSkipReasonsUsecase(getIt()))
    ..registerLazySingleton(() => TurnOffKatmUsecase(getIt()))
    // Bloc — har biri o'z ekrani uchun.
    ..registerFactory(
      () => ProductPickerBloc(
        suppliers: getIt(),
        categories: getIt(),
        brands: getIt(),
        variants: getIt(),
        scanImei: getIt(),
      ),
    )
    // Fayl imzolangan S3 havolasidan olinadi — bizning `Authorization`
    // sarlavhamiz unga kerak emas, shuning uchun interceptorsiz klient.
    ..registerLazySingleton(() => ContractFileRemoteDatasource(dio: getIt<UploadClient>().dio))
    ..registerLazySingleton<ContractFileRepository>(() => ContractFileRepositoryImpl(remote: getIt()))
    ..registerLazySingleton(() => DownloadContractFileUsecase(getIt()))
    ..registerFactoryParam<ContractDetailsBloc, int, void>(
      (int contractId, void _) =>
          ContractDetailsBloc(contractId: contractId, getDetails: getIt(), downloadFile: getIt()),
    )
    ..registerFactoryParam<ContractCreateBloc, ContractCreateArgs, void>(
      (ContractCreateArgs args, void _) => ContractCreateBloc(
        args: args,
        getDetails: getIt(),
        getPaymentDays: getIt(),
        getOccupations: getIt(),
        submit: getIt(),
        changes: getIt(),
      ),
    )
    ..registerFactoryParam<ContractProductsBloc, ContractCreateArgs, void>(
      (ContractCreateArgs args, void _) => ContractProductsBloc(
        args: args,
        getDetails: getIt(),
        createDraft: getIt(),
        addProduct: getIt(),
        updateProduct: getIt(),
        deleteProduct: getIt(),
      ),
    )
    ..registerFactoryParam<ContractCardBloc, ({int contractId, int clientId}), ContractCard>(
      (({int contractId, int clientId}) ids, ContractCard? card) => ContractCardBloc(
        contractId: ids.contractId,
        clientId: ids.clientId,
        card: card ?? const ContractCard(id: 0, number: '', phone: '', month: 0, year: 0),
        addCard: getIt(),
        removeCard: getIt(),
      ),
    )
    ..registerFactoryParam<ContractGuarantorsBloc, ({int contractId, int clientId}), List<ContractGuarantor>>(
      (({int contractId, int clientId}) ids, List<ContractGuarantor>? guarantors) => ContractGuarantorsBloc(
        contractId: ids.contractId,
        clientId: ids.clientId,
        guarantors: guarantors ?? const <ContractGuarantor>[],
        addGuarantor: getIt(),
        removeGuarantor: getIt(),
      ),
    )
    ..registerFactoryParam<PaymentScheduleBloc, ScheduleQuery, void>(
      (ScheduleQuery query, void _) => PaymentScheduleBloc(query: query, getSchedule: getIt()),
    )
    ..registerFactoryParam<SpecialTariffBloc, ({int contractId, int termMonths}), AppliedTariff>(
      (({int contractId, int termMonths}) ids, AppliedTariff? applied) => SpecialTariffBloc(
        contractId: ids.contractId,
        termMonths: ids.termMonths,
        applied: applied ?? const AppliedTariff(id: 0, name: '', isActive: false),
        getAvailable: getIt(),
        apply: getIt(),
        remove: getIt(),
        getApplied: getIt(),
      ),
    )
    ..registerFactoryParam<ManagerBonusBloc, ContractBenefit, void>(
      (ContractBenefit benefit, void _) => ManagerBonusBloc(benefit: benefit, send: getIt()),
    )
    ..registerFactoryParam<KatmSkipBloc, int, ({String mib, String katm})>(
      (int contractId, ({String mib, String katm})? reasons) => KatmSkipBloc(
        contractId: contractId,
        mibFailReason: reasons?.mib ?? '',
        katmFailReason: reasons?.katm ?? '',
        getReasons: getIt(),
        turnOff: getIt(),
      ),
    );
}

/// Anderrayter featurei: daromadni tasdiqlovchi hujjatlar.
void _registerUnderwriter() {
  getIt
    // Imzolangan S3 havolasiga yozish uchun interceptorsiz klient.
    ..registerLazySingleton(createUploadClient)
    ..registerLazySingleton(() => UnderwriterRemoteDatasource(dio: getIt(), upload: getIt()))
    ..registerLazySingleton<UnderwriterRepository>(() => UnderwriterRepositoryImpl(remote: getIt()))
    ..registerLazySingleton(() => LoadUnderwriterUsecase(getIt()))
    ..registerLazySingleton(() => LoadReferencesUsecase(getIt()))
    ..registerLazySingleton(() => GetCarModelsUsecase(getIt()))
    ..registerLazySingleton(() => UploadDocumentUsecase(getIt()))
    ..registerLazySingleton(() => SaveUnderwriterUsecase(getIt()))
    ..registerFactoryParam<UnderwriterBloc, UnderwriterArgs, void>(
      (UnderwriterArgs args, void _) => UnderwriterBloc(
        args: args,
        load: getIt(),
        getReferences: getIt(),
        getModels: getIt(),
        upload: getIt(),
        save: getIt(),
        // Sana tashqaridan: ish haqi oylari va avtomobil yillari shunga
        // bog'liq va testda qotirib qo'yilishi kerak (9.4).
        today: DateTime.now,
      ),
    );
}

/// Chiqim tovarlar. Tartib: datasource → repository → usecase → bloc (8.5).
void _registerOutputs() {
  getIt
    ..registerLazySingleton(() => OutputsRemoteDatasource(dio: getIt(), now: DateTime.now))
    ..registerLazySingleton(() => OutputReleaseRemoteDatasource(dio: getIt()))
    ..registerLazySingleton(() => IcloudRemoteDatasource(dio: getIt()))
    ..registerLazySingleton<OutputsRepository>(() => OutputsRepositoryImpl(remote: getIt()))
    ..registerLazySingleton<OutputReleaseRepository>(() => OutputReleaseRepositoryImpl(remote: getIt()))
    ..registerLazySingleton<IcloudRepository>(() => IcloudRepositoryImpl(remote: getIt()))
    ..registerLazySingleton(() => GetOutputContractsUsecase(getIt()))
    ..registerLazySingleton(() => GetOutputProductsUsecase(getIt()))
    ..registerLazySingleton(() => ConfirmReleaseUsecase(getIt()))
    ..registerLazySingleton(() => ReturnProductsUsecase(getIt()))
    ..registerLazySingleton(() => GetIcloudRequirementsUsecase(getIt()))
    ..registerLazySingleton(() => SaveIcloudCredentialUsecase(getIt()))
    ..registerFactory(
      () => OutputsBloc(
        getContracts: getIt(),
        getProducts: getIt(),
        returnProducts: getIt(),
        changes: getIt(),
      ),
    )
    ..registerFactoryParam<ReleaseBloc, OutputContract, void>(
      (OutputContract contract, _) =>
          ReleaseBloc(
            contract: contract,
            getRequirements: getIt(),
            confirmRelease: getIt(),
            changes: getIt(),
          ),
    )
    ..registerFactoryParam<RequirementsBloc, int, void>(
      (int contractId, _) => RequirementsBloc(contractId: contractId, getRequirements: getIt()),
    )
    // Forma bitta qurilmaga bog'lanadi: qurilma, mijoz ismi va shartnoma
    // birga keladi.
    ..registerFactoryParam<CredentialBloc, ({int contractId, String clientName, IcloudDevice device}), void>(
      (({int contractId, String clientName, IcloudDevice device}) args, _) => CredentialBloc(
        device: args.device,
        clientName: args.clientName,
        contractId: args.contractId,
        save: getIt(),
      ),
    );
}

void _registerInvoices() {
  getIt.registerFactory(() => InvoicesBloc());
}