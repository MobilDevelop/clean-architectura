import 'dart:io';

import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/router/contract_create_routes.dart';
import 'package:colloborator_v3/core/router/routes.dart';
import 'package:colloborator_v3/features/auth/login/presentation/bloc/login_bloc.dart';
import 'package:colloborator_v3/features/auth/login/presentation/bloc/login_event.dart';
import 'package:colloborator_v3/features/auth/registration/presentation/bloc/registration_bloc.dart';
import 'package:colloborator_v3/features/auth/registration/presentation/pages/registration_page.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts_event.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/presentation/details/contract_details_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/picker/product_picker_bloc.dart';

import 'package:colloborator_v3/features/contract_create/presentation/details/contract_details_page.dart';
import 'package:colloborator_v3/features/contract_create/presentation/picker/product_picker_page.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_result_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/pages/contract_result_page.dart';
import 'package:colloborator_v3/features/contracts/presentation/pages/contracts_page.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/add_customer_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/face_id_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/pages/add_customer_page.dart';
import 'package:colloborator_v3/features/customers/presentation/pages/face_camera_page.dart';
import 'package:colloborator_v3/features/customers/presentation/pages/client_verify_page.dart';
import 'package:colloborator_v3/features/customers/presentation/pages/face_id_page.dart';
import 'package:colloborator_v3/features/customers/presentation/pages/customer_page.dart';
import 'package:colloborator_v3/features/invoices/presentation/bloc/invoices_bloc.dart';
import 'package:colloborator_v3/features/invoices/presentation/pages/invoices_page.dart';
import 'package:colloborator_v3/features/outputs/presentation/bloc/outputs_bloc.dart';
import 'package:colloborator_v3/features/outputs/presentation/pages/outputs_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:colloborator_v3/core/services/auth_notifier.dart';
import 'package:colloborator_v3/core/services/push_notifications.dart';
import 'package:colloborator_v3/core/widgets/states/route_error_view.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/auth/login/presentation/pages/login_page.dart';
import 'package:colloborator_v3/features/main/presentation/pages/main_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  AppRouter(this._auth, this._push) {
    // Bildirishnoma bosildi — foydalanuvchi qaysi ekranda bo'lishidan qat'i
    // nazar shartnomalar ro'yxatiga o'tiladi. Xabarning o'zini `ContractsBloc`
    // oladi (`takePending`), bu yerda faqat marshrut: navigatsiya bloc ichida
    // bo'lmasligi kerak (6.2).
    _opened = _push.opened.listen((_) => router.go(Routes.contracts.path));
  }

  final AuthNotifier _auth;
  final PushNotifications _push;

  StreamSubscription<PushMessage>? _opened;

  /// `AppRouter` ilova bilan tug'ilib ilova bilan o'ladi, shuning uchun bu
  /// hozircha chaqirilmaydi — `FirebaseService.dispose()` ham shunday. Obuna
  /// egasiz qolmasligi kerak: `cancel_subscriptions` qoidasi shuni talab qiladi.
  Future<void> dispose() async {
    await _opened?.cancel();
    _opened = null;
  }

  late final GoRouter router = GoRouter(
    initialLocation: Routes.login.path,
    debugLogDiagnostics: true,
    refreshListenable: _auth,
    navigatorKey: CustomAnimatedToast.navigatorKey,
    redirect: (context, state) {
      final publicPaths = {Routes.login.path, Routes.registration.path};
      final isPublic = publicPaths.contains(state.matchedLocation);

      if (!_auth.isAuthenticated && !isPublic) return Routes.login.path;
      if (_auth.isAuthenticated && isPublic) return Routes.customer.path;

      // Sovuq start: bildirishnoma ilovani ishga tushirgan bo'lsa, `opened`
      // oqimi `AppRouter` yaratilishidan oldin o'tib ketadi va tinglovchi uni
      // ko'rmaydi. Shuning uchun kutib turgan bosish shu yerda ham
      // tekshiriladi — aks holda bosish faqat foydalanuvchi shartnomalar
      // tabiga o'zi kirganda ishlab qolardi.
      if (_auth.isAuthenticated && _push.hasPending && state.matchedLocation != Routes.contracts.path) {
        return Routes.contracts.path;
      }

      return null;
    },
    routes: <RouteBase>[

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainPage(shell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.customer.name,
                path: Routes.customer.path,
                builder: (context, state) => BlocProvider(
                  create: (context) => getIt<CustomersBloc>(),
                  child: const CustomerPage(),
                ),
              ),
            ],
          ),
          
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.contracts.name,
                path: Routes.contracts.path,
                builder: (context, state) => BlocProvider(
                  create: (context) => getIt<ContractsBloc>()..add(const ContractsGet()),
                  child: const ContractsPage(),
                ),
              ),
            ]
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.outputs.name,
                path: Routes.outputs.path,
                builder: (context, state) => BlocProvider(
                  create: (context) => getIt<OutputsBloc>(),
                  child: const OutputsPage(),
                ),
              ),
            ]
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.invoices.name,
                path: Routes.invoices.path,
                builder: (context, state) => BlocProvider(
                  create: (context) => getIt<InvoicesBloc>(),
                  child: const InvoicesPage(),
                ),
              ),
            ]
          ),
        ],
      ),

      GoRoute(
        name: Routes.login.name,
        path: Routes.login.path,
        pageBuilder: (context, state) => buildScaleTransitionPage<void>(
          context: context,
          state: state,
          child: BlocProvider(
            create: (context) => getIt<LoginBloc>()..add(const LoginStarted()),
            child: const LoginPage(),
          ),
        ),
      ),

      GoRoute( 
        name: Routes.registration.name,
        path: Routes.registration.path,
        pageBuilder: (context, state) => buildScaleTransitionPage<void>(
          context: context,
          state: state,
          child: BlocProvider(
            create: (context) => getIt<RegistrationBloc>(),
            child: const RegistrationPage(),
          ),
        ),
      ),

      GoRoute(
        name: Routes.productPicker.name,
        path: Routes.productPicker.path,
        pageBuilder: (context, state) => buildScaleTransitionPage<ProductDraft>(
          context: context,
          state: state,
          child: BlocProvider(
            create: (context) => getIt<ProductPickerBloc>(),
            child: const ProductPickerPage(),
          ),
        ),
      ),

      ...contractCreateRoutes(),

      GoRoute(
        name: Routes.contractDetails.name,
        path: Routes.contractDetails.path,
        pageBuilder: (context, state) {
          final extra = state.extra;

          if (extra is! int) {
            return buildScaleTransitionPage<void>(
              context: context,
              state: state,
              child: RouteErrorView(location: state.uri.toString(), onBack: () => context.go(Routes.contracts.path)),
            );
          }

          return buildScaleTransitionPage<void>(
            context: context,
            state: state,
            child: BlocProvider(
              create: (context) => getIt<ContractDetailsBloc>(param1: extra)..add(const DetailsRequested()),
              child: const ContractDetailsPage(),
            ),
          );
        },
      ),

      GoRoute(
        name: Routes.contractResult.name,
        path: Routes.contractResult.path,
        pageBuilder: (context, state) {
          final extra = state.extra;

          if (extra is! ContractInfo) {
            return buildScaleTransitionPage<void>(
              context: context,
              state: state,
              child: RouteErrorView(location: state.uri.toString(), onBack: () => context.go(Routes.contracts.path)),
            );
          }

          return buildScaleTransitionPage<void>(
            context: context,
            state: state,
            child: BlocProvider(
              create: (context) =>
                  getIt<ContractResultBloc>(param1: extra.id, param2: extra.flex)..add(const ScoringRequested()),
              child: const ContractResultPage(),
            ),
          );
        },
      ),

      GoRoute(
        name: Routes.addCustomer.name,
        path: Routes.addCustomer.path,
        pageBuilder: (context, state) {
          final extra = state.extra;

          // Ekran mijozsiz ma'nosiz — noto'g'ri chaqiruv jimgina bo'sh sahifa
          // bermasin.
          if (extra is! ({CustomerInfo info, bool isEdit})) {
            return buildScaleTransitionPage<void>(
              context: context,
              state: state,
              child: RouteErrorView(location: state.uri.toString(), onBack: () => context.go(Routes.customer.path)),
            );
          }

          return buildScaleTransitionPage<bool>(
            context: context,
            state: state,
            child: BlocProvider(
              create: (context) => getIt<AddCustomerBloc>(param1: extra.info, param2: extra.isEdit)..add(const AddCustomerStarted()),
              child: AddCustomerPage(isEdit: extra.isEdit),
            ),
          );
        },
      ),

      GoRoute(
        name: Routes.clientVerify.name,
        path: Routes.clientVerify.path,
        pageBuilder: (context, state) {
          final extra = state.extra;

          if (extra is! ({CustomerInfo customer, String reason})) {
            return buildScaleTransitionPage<CustomerInfo>(
              context: context,
              state: state,
              child: RouteErrorView(location: state.uri.toString(), onBack: () => context.pop()),
            );
          }

          return buildScaleTransitionPage<CustomerInfo>(
            context: context,
            state: state,
            child: BlocProvider(
              create: (context) => getIt<FaceIdBloc>(),
              child: ClientVerifyPage(customer: extra.customer, reason: extra.reason),
            ),
          );
        },
      ),

      GoRoute(
        name: Routes.faceCamera.name,
        path: Routes.faceCamera.path,
        pageBuilder: (context, state) => buildScaleTransitionPage<File>(
          context: context,
          state: state,
          child: const FaceCameraPage(),
        ),
      ),

      GoRoute(
        name: Routes.faceId.name,
        path: Routes.faceId.path,
        pageBuilder: (context, state) => buildScaleTransitionPage<CustomerInfo>(
          context: context,
          state: state,
          child: BlocProvider(
            create: (context) => getIt<FaceIdBloc>(),
            child: const FaceIdPage(),
          ),
        ),
      ),

    ],
    errorBuilder: (context, state) => RouteErrorView(
      location: state.uri.toString(),
      onBack: () => context.go(Routes.customer.path),
    ),
  );
}

CustomTransitionPage<T> buildScaleTransitionPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => ScaleTransition(scale: animation, child: child));
}
