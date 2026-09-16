import 'dart:async';
import 'dart:io';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/payment_schedule.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bloc/payment_schedule/payment_schedule_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/schedule/schedule_date_text.dart';
import 'package:colloborator_v3/features/contract_create/presentation/shared/spoke_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

/// To'lov jadvali — faqat o'qish uchun.
///
/// Alohida ekran: 24 qatorli jadval muddat stepperi ostiga sig'maydi va uni
/// ko'mib yuboradi.
final class PaymentSchedulePage extends StatelessWidget {
  const PaymentSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentScheduleBloc, PaymentScheduleState>(
      listenWhen: (PaymentScheduleState previous, PaymentScheduleState current) =>
          current.shareFile != null && current.shareFile != previous.shareFile,
      listener: (BuildContext context, PaymentScheduleState state) {
        final File? file = state.shareFile;
        if (file != null) unawaited(_share(context, file));
      },
      builder: (BuildContext context, PaymentScheduleState state) {
        final PaymentScheduleBloc bloc = context.read<PaymentScheduleBloc>();

        return SpokeScaffold(
          title: "To'lov jadvali",
          failure: state.failure,
          failureHandled: () => bloc.add(const FailureHandled()),
          retryPress: () => bloc.add(const ScheduleRequested()),
          backPress: () => context.pop(),
          isLoading: state.isLoading && !state.isLoaded,
          bottom: state.canShare ? _shareButton(bloc, state) : null,
          child: _body(state),
        );
      },
    );
  }

  /// Ulashish oynasi — UI ta'siri, shuning uchun bloc emas, sahifa ochadi (6.2).
  Future<void> _share(BuildContext context, File file) async {
    context.read<PaymentScheduleBloc>().add(const ScheduleFileShared());

    await SharePlus.instance.share(ShareParams(files: <XFile>[XFile(file.path)]));
  }

  Widget _shareButton(PaymentScheduleBloc bloc, PaymentScheduleState state) => MainButton(
    text: "Jadvalni ulashish",
    leftIcon: AppIcons.file,
    margin: EdgeInsets.symmetric(horizontal: ScreenSize.h16, vertical: ScreenSize.h8),
    showLoading: state.isSharing,
    onPressed: () => bloc.add(const ScheduleShareRequested()),
  );

  Widget _body(PaymentScheduleState state) {
    // Bo'sh jadval va tarmoq xatosi bir xil ko'rinmaydi: flex ikkalasini ham
    // bo'sh oq maydon qilib ko'rsatardi.
    if (state.isLoaded && state.schedule.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(ScreenSize.h24),
          child: Text(
            "Server bu shartlar uchun jadval qaytarmadi",
            textAlign: TextAlign.center,
            style: AppTheme.data.textTheme.bodySmall,
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h16, ScreenSize.h16, ScreenSize.h24),
      children: <Widget>[
        _summary(state),
        Gap(ScreenSize.h12),

        for (final ScheduleRow row in state.schedule.rows) _row(row),
      ],
    );
  }

  Widget _summary(PaymentScheduleState state) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(ScreenSize.h14),
    decoration: BoxDecoration(
      color: AppTheme.colors.primary.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(ScreenSize.r18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Oylik to'lov", style: AppTheme.data.textTheme.bodySmall),
        Gap(ScreenSize.h2),
        Text(
          Money.withUnit(state.schedule.monthly),
          style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.primary),
        ),
        Gap(ScreenSize.h8),
        Text(
          "${state.schedule.rows.length} ta to'lov · jami ${Money.withUnit(state.schedule.total)}",
          style: AppTheme.data.textTheme.bodySmall,
        ),
      ],
    ),
  );

  Widget _row(ScheduleRow row) => Container(
    margin: EdgeInsets.only(bottom: ScreenSize.h8),
    padding: EdgeInsets.symmetric(horizontal: ScreenSize.h14, vertical: ScreenSize.h12),
    decoration: BoxDecoration(
      color: AppTheme.colors.white,
      borderRadius: BorderRadius.circular(ScreenSize.r14),
      border: AppSurface.border(alpha: .5),
    ),
    child: Row(
      children: <Widget>[
        SizedBox(
          width: ScreenSize.h28,
          child: Text("${row.number}", style: AppTheme.data.textTheme.bodySmall),
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                ScheduleDateText.of(row.date),
                style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),

        Text(
          Money.withUnit(row.amount),
          style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
        ),
      ],
    ),
  );
}
