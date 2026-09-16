import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/card_expiry_formatter.dart';
import 'package:colloborator_v3/core/utils/formatter/card_formatter.dart';
import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_instruments.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bloc/guarantor_instruments/guarantor_instruments_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/guarantors/instruments_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Kafilning instrumentlarini tahrirlash oynasi.
///
/// `true` qaytsa — saqlandi va chaqiruvchi shartnomani qayta o'qishi kerak.
Future<bool> showInstrumentsSheet({
  required BuildContext context,
  required int contractId,
  required int clientId,
}) async {
  final bool? isSaved = await showAppSheet<bool>(
    context: context,
    child: BlocProvider<InstrumentsBloc>(
      create: (BuildContext context) =>
          getIt<InstrumentsBloc>(param1: GuarantorRef(contractId: contractId, clientId: clientId))
            ..add(const InstrumentsStarted()),
      child: const _InstrumentsSheet(),
    ),
  );

  return isSaved ?? false;
}

final class _InstrumentsSheet extends StatefulWidget {
  const _InstrumentsSheet();

  @override
  State<_InstrumentsSheet> createState() => _InstrumentsSheetState();
}

final class _InstrumentsSheetState extends State<_InstrumentsSheet> {
  final TextEditingController _number = TextEditingController();
  final TextEditingController _expiry = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  @override
  void dispose() {
    _number.dispose();
    _expiry.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InstrumentsBloc, InstrumentsState>(
      listenWhen: (InstrumentsState previous, InstrumentsState current) => current.isSaved && !previous.isSaved,
      listener: (BuildContext context, InstrumentsState state) => context.pop(true),
      builder: (BuildContext context, InstrumentsState state) {
        final InstrumentsBloc bloc = context.read<InstrumentsBloc>();

        return FailureView(
          failure: state.failure,
          onHandled: () => bloc.add(const InstrumentsFailureHandled()),
          onRetry: () => bloc.add(const InstrumentsRetried()),
          child: Padding(
            padding: EdgeInsets.only(
              left: ScreenSize.h16,
              right: ScreenSize.h16,
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    InstrumentsText.title,
                    textAlign: TextAlign.center,
                    style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
                  ),

                  Gap(ScreenSize.h4),
                  Text(
                    InstrumentsText.subtitle,
                    textAlign: TextAlign.center,
                    style: AppTheme.data.textTheme.bodySmall,
                  ),

                  Gap(ScreenSize.h16),
                  if (!state.isReady) _loading() else ..._form(state, bloc),

                  Gap(ScreenSize.h12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _loading() => Padding(
    padding: EdgeInsets.symmetric(vertical: ScreenSize.h32),
    child: Center(child: CircularProgressIndicator(color: AppTheme.colors.primary)),
  );

  List<Widget> _form(InstrumentsState state, InstrumentsBloc bloc) => <Widget>[
    for (final InstrumentType type in InstrumentType.values) ...<Widget>[
      _tile(type, state, bloc),
      Gap(ScreenSize.h8),
    ],

    if (state.conflict case final InstrumentType conflict) ...<Widget>[
      Text(
        InstrumentsText.conflict(conflict),
        style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.red),
      ),
      Gap(ScreenSize.h8),
    ],

    if (state.showCard) ..._card(state, bloc),

    Gap(ScreenSize.h8),
    MainButton(
      text: InstrumentsText.save,
      showLoading: state.isSaving,
      onPressed: () => bloc.add(const InstrumentsSubmitted()),
    ),
  ];

  Widget _tile(InstrumentType type, InstrumentsState state, InstrumentsBloc bloc) {
    final bool isOn = state.selected.contains(type);

    return InkWell(
      onTap: state.isSaving ? null : () => bloc.add(InstrumentToggled(type)),
      borderRadius: BorderRadius.circular(ScreenSize.r14),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12, vertical: ScreenSize.h12),
        decoration: BoxDecoration(
          color: isOn ? AppTheme.colors.primary.withValues(alpha: .06) : AppTheme.colors.backcolor,
          borderRadius: BorderRadius.circular(ScreenSize.r14),
          border: isOn ? Border.all(color: AppTheme.colors.primary.withValues(alpha: .35)) : AppSurface.border(),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              isOn ? Icons.check_circle : Icons.circle_outlined,
              size: ScreenSize.h20,
              color: isOn ? AppTheme.colors.primary : AppTheme.colors.grey,
            ),

            Gap(ScreenSize.w10),
            Expanded(
              child: Text(
                InstrumentsText.of(type),
                style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Serverda karta bo'lsa niqobi ko'rsatiladi: xodim qaysi karta
  /// saqlanganini biladi va tegmasa qayta kiritishi shart emas.
  List<Widget> _card(InstrumentsState state, InstrumentsBloc bloc) => <Widget>[
    if (state.server?.card case final InstrumentCardInfo saved) ...<Widget>[
      Text(
        "Saqlangan karta: ${saved.mask}${saved.expire.isEmpty ? '' : ', ${saved.expire}'}",
        style: AppTheme.data.textTheme.bodySmall,
      ),
      Gap(ScreenSize.h8),
    ],

    TextInputWidget(
      title: "Karta raqami",
      hint: "#### #### #### ####",
      controller: _number,
      errorText: InstrumentsText.card(state.issue),
      enabled: !state.isSaving,
      keyboardType: TextInputType.number,
      formatters: <TextInputFormatter>[CardFormatter()],
      onChanged: (String value) => bloc.add(InstrumentCardChanged(number: value.replaceAll(' ', ''))),
    ),

    Gap(ScreenSize.h10),
    Row(
      children: <Widget>[
        Expanded(
          child: TextInputWidget(
            title: "Muddati",
            hint: "##/##",
            controller: _expiry,
            errorText: InstrumentsText.expiry(state.issue),
            enabled: !state.isSaving,
            keyboardType: TextInputType.number,
            formatters: <TextInputFormatter>[CardExpiryFormatter()],
            onChanged: (String value) => bloc.add(InstrumentCardChanged(expiry: value)),
          ),
        ),

        Gap(ScreenSize.w10),
        Expanded(
          child: TextInputWidget(
            title: "Telefon",
            hint: "+998 ## ###-##-##",
            controller: _phone,
            errorText: InstrumentsText.phone(state.issue),
            enabled: !state.isSaving,
            keyboardType: TextInputType.phone,
            formatters: <TextInputFormatter>[PhoneFormatter()],
            onChanged: (String value) =>
                bloc.add(InstrumentCardChanged(phone: value.replaceAll(RegExp('[^0-9]'), ''))),
          ),
        ),
      ],
    ),
  ];
}
