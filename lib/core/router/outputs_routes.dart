import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/router/coordinator.dart';
import 'package:colloborator_v3/core/router/routes.dart';
import 'package:colloborator_v3/core/widgets/states/route_error_view.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';
import 'package:colloborator_v3/features/outputs/presentation/bloc/credential/credential_bloc.dart';
import 'package:colloborator_v3/features/outputs/presentation/bloc/requirements/requirements_bloc.dart';
import 'package:colloborator_v3/features/outputs/presentation/credential/credential_page.dart';
import 'package:colloborator_v3/features/outputs/presentation/requirements/requirements_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Chiqim berishdan oldingi qurilma ekranlari.
///
/// Nega alohida fayl: `coordinator.dart` ilovaning butun daraxtini saqlaydi
/// va bir featurening o'sishi bilan o'sib ketmasligi kerak.
typedef _RequirementsArgs = ({int contractId, String clientName});
typedef _CredentialArgs = ({int contractId, String clientName, IcloudDevice device});

List<RouteBase> outputsRoutes() => <RouteBase>[
  GoRoute(
    name: Routes.icloudRequirements.name,
    path: Routes.icloudRequirements.path,
    pageBuilder: (BuildContext context, GoRouterState state) {
      final Object? extra = state.extra;

      if (extra is! _RequirementsArgs) {
        return buildScaleTransitionPage<void>(
          context: context,
          state: state,
          child: RouteErrorView(location: state.uri.toString(), onBack: context.pop),
        );
      }

      return buildScaleTransitionPage<void>(
        context: context,
        state: state,
        child: BlocProvider<RequirementsBloc>(
          create: (BuildContext context) =>
              getIt<RequirementsBloc>(param1: extra.contractId)..add(const RequirementsRequested()),
          child: RequirementsPage(
            credentialOpener: (BuildContext context, IcloudDevice device) => context.push<bool>(
              Routes.icloudCredential.path,
              extra: (contractId: extra.contractId, clientName: extra.clientName, device: device),
            ),
          ),
        ),
      );
    },
  ),

  GoRoute(
    name: Routes.icloudCredential.name,
    path: Routes.icloudCredential.path,
    pageBuilder: (BuildContext context, GoRouterState state) {
      final Object? extra = state.extra;

      if (extra is! _CredentialArgs) {
        return buildScaleTransitionPage<bool>(
          context: context,
          state: state,
          child: RouteErrorView(location: state.uri.toString(), onBack: context.pop),
        );
      }

      return buildScaleTransitionPage<bool>(
        context: context,
        state: state,
        child: BlocProvider<CredentialBloc>(
          create: (BuildContext context) => getIt<CredentialBloc>(param1: extra),
          child: const CredentialPage(),
        ),
      );
    },
  ),
];
