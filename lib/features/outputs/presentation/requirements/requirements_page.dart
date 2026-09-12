import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/core/widgets/states/pull_refresh.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';
import 'package:colloborator_v3/features/outputs/presentation/requirements/device_tile.dart';
import 'package:colloborator_v3/features/outputs/presentation/requirements/requirements_bloc.dart';
import 'package:colloborator_v3/features/outputs/presentation/requirements/requirements_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Chiqimdan oldin to'ldirilishi kerak bo'lgan qurilmalar.
final class RequirementsPage extends StatelessWidget {
  const RequirementsPage({super.key, required this.credentialOpener});

  /// Bitta qurilmaning formasini ochadi. Marshrut nomi sahifada turmasligi
  /// uchun tashqaridan beriladi (1.3).
  final Future<bool?> Function(BuildContext context, IcloudDevice device) credentialOpener;

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;
    final RequirementsBloc bloc = context.read<RequirementsBloc>();

    return Scaffold(
      backgroundColor: AppTheme.colors.backcolor,
      body: BlocSelector<RequirementsBloc, RequirementsState, Failure?>(
        selector: (RequirementsState state) => state.failure,
        builder: (BuildContext context, Failure? failure) => FailureView(
          failure: failure,
          onHandled: () => bloc.add(const FailureHandled()),
          onRetry: () => bloc.add(const Retried()),
          child: Stack(
            children: <Widget>[
              const BackgroundWash(),

              Positioned.fill(
                child: BlocBuilder<RequirementsBloc, RequirementsState>(
                  builder: (BuildContext context, RequirementsState state) =>
                      PullRefresh<RequirementsBloc, RequirementsState>(
                        isLoading: (RequirementsState state) => state.isLoading,
                        refreshPress: () => bloc.add(const RequirementsRequested()),
                        edgeOffset: topInset + ScreenSize.h56,
                        child: _content(context, state, topInset + ScreenSize.h56),
                      ),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: PageHeader(
                  title: RequirementsText.title,
                  topInset: topInset,
                  backPress: context.pop,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, RequirementsState state, double topPadding) {
    final EdgeInsets padding = EdgeInsets.only(top: topPadding + ScreenSize.h12, bottom: ScreenSize.h24);

    if (state.isLoading && state.requirements == null) {
      return ListView(
        padding: padding,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: ScreenSize.h40),
            child: Center(child: CircularProgressIndicator(color: AppTheme.colors.primary)),
          ),
        ],
      );
    }

    if (state.isEmpty) {
      return ListView(
        padding: padding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: const <Widget>[
          EmptyPlaceholder(
            icon: AppIcons.product,
            title: RequirementsText.emptyTitle,
            message: RequirementsText.emptyMessage,
          ),
        ],
      );
    }

    final List<IcloudDevice> devices = state.devices;

    return ListView.builder(
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      // Oxirgi o'rin — hamma to'ldirilgani haqidagi yozuv.
      itemCount: devices.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == devices.length) return _satisfied(state);

        final IcloudDevice device = devices[index];

        return DeviceTile(
          key: ValueKey<int>(device.contractProductId),
          device: device,
          onTap: () => _open(context, device),
        );
      },
    );
  }

  /// Forma saqlangach ro'yxat qaytadan o'qiladi: qaysi qurilma to'ldirilgani
  /// va chiqim ochilgan-ochilmagani serverdan aniqlanadi.
  Future<void> _open(BuildContext context, IcloudDevice device) async {
    final RequirementsBloc bloc = context.read<RequirementsBloc>();
    final bool? saved = await credentialOpener(context, device);

    if (saved != true) return;

    bloc.add(const RequirementsRequested());
  }

  Widget _satisfied(RequirementsState state) {
    final IcloudRequirements? requirements = state.requirements;

    if (requirements == null || !requirements.isSatisfied) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12, vertical: ScreenSize.h8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.check_circle_rounded, size: ScreenSize.h18, color: AppTheme.colors.green),

          Gap(ScreenSize.w8),
          Text(
            RequirementsText.satisfied,
            style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.green),
          ),
        ],
      ),
    );
  }
}
