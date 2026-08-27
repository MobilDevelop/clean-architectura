import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/router/routes.dart';
import 'package:colloborator_v3/features/auth/login/presentation/bloc/login_bloc.dart';
import 'package:colloborator_v3/features/auth/login/presentation/bloc/login_event.dart';
import 'package:colloborator_v3/features/auth/registration/presentation/bloc/registration_bloc.dart';
import 'package:colloborator_v3/features/auth/registration/presentation/pages/registration_page.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts_event.dart';
import 'package:colloborator_v3/features/contracts/presentation/pages/contracts_page.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/pages/customer_page.dart';
import 'package:colloborator_v3/features/invoices/presentation/bloc/invoices_bloc.dart';
import 'package:colloborator_v3/features/invoices/presentation/pages/invoices_page.dart';
import 'package:colloborator_v3/features/outputs/presentation/bloc/outputs_bloc.dart';
import 'package:colloborator_v3/features/outputs/presentation/pages/outputs_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:colloborator_v3/core/services/auth_notifier.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/auth/login/presentation/pages/login_page.dart';
import 'package:colloborator_v3/features/main/presentation/pages/main_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  AppRouter(this._auth);

  final AuthNotifier _auth;

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
        pageBuilder: (context, state) => buildPageWithDefaultTransition1<void>(
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
        pageBuilder: (context, state) => buildPageWithDefaultTransition1<void>(
          context: context,
          state: state,
          child: BlocProvider(
            create: (context) => getIt<RegistrationBloc>(),
            child: const RegistrationPage(),
          ),
        ),
      ),

    ],
    errorBuilder: (context, state) => const SizedBox(),
  );
}

CustomTransitionPage<T> buildPageWithDefaultTransition1<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => ScaleTransition(scale: animation, child: child));
}

CustomTransitionPage<T> buildPageWithDefaultTransition2<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<T> buildPageWithDefaultTransition3<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final Offset begin = Offset(0.0, 1.0);
      final Offset end = Offset.zero;
      final Tween<Offset> offsetTween = Tween(begin: begin, end: end);
      final Animation<Offset> offsetAnimation = animation.drive(offsetTween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

CustomTransitionPage<T> buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final Offset begin = Offset(1.0, 0.0);
      final Offset end = Offset.zero;
      final Tween<Offset> offsetTween = Tween(begin: begin, end: end);
      final Animation<Offset> offsetAnimation = animation.drive(offsetTween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}