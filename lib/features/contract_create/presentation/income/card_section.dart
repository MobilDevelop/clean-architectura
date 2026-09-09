import 'dart:async';

import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/presentation/income/card_form_section.dart';
import 'package:colloborator_v3/features/contract_create/presentation/income/contract_card_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Karta aylanmasi — bitta qator, forma esa oynada.
///
/// Nega oynada: forma ekranga qo'yilganda unda o'z "Saqlash" tugmasi paydo
/// bo'ladi va u pastdagi "Yuborish" bilan yonma-yon turadi. Bitta ekranda
/// ikkita birlamchi tugma bo'lsa, foydalanuvchi qaysi biri shartnomani
/// yakunlashini bilmaydi.
final class CardSection extends StatefulWidget {
  const CardSection({super.key, required this.isEnabled, required this.disabledReason, required this.saved});

  /// Norasmiy daromadda karta so'ralmaydi.
  final bool isEnabled;
  final String disabledReason;

  /// Serverda karta o'zgardi — shartnoma qayta o'qiladi.
  final VoidCallback saved;

  @override
  State<CardSection> createState() => _CardSectionState();
}

final class _CardSectionState extends State<CardSection> {
  late final TextEditingController _phone;
  late final TextEditingController _number;
  late final TextEditingController _expiry;

  // Fokus tugunlari kontrollerlar bilan birga shu yerda yashaydi: oyna
  // yopilib-ochilganda ular yo'qolmasligi kerak.
  late final FocusNode _phoneFocus;
  late final FocusNode _numberFocus;
  late final FocusNode _expiryFocus;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController();
    _number = TextEditingController();
    _expiry = TextEditingController();
    _phoneFocus = FocusNode();
    _numberFocus = FocusNode();
    _expiryFocus = FocusNode();
  }

  @override
  void dispose() {
    _phone.dispose();
    _number.dispose();
    _expiry.dispose();
    _phoneFocus.dispose();
    _numberFocus.dispose();
    _expiryFocus.dispose();
    super.dispose();
  }

  Future<void> _openForm(BuildContext context) => showAppSheet(
    context: context,
    // Oyna ildiz navigatorda ochiladi — bloc unga qo'lda uzatiladi.
    child: BlocProvider<ContractCardBloc>.value(
      value: context.read<ContractCardBloc>(),
      child: _CardSheet(
        phone: _phone,
        number: _number,
        expiry: _expiry,
        phoneFocus: _phoneFocus,
        numberFocus: _numberFocus,
        expiryFocus: _expiryFocus,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContractCardBloc, ContractCardState>(
      listenWhen: (ContractCardState previous, ContractCardState current) =>
          current.revision != previous.revision,
      listener: (BuildContext context, ContractCardState state) {
        _phone.clear();
        _number.clear();
        _expiry.clear();
        widget.saved();
      },
      builder: (BuildContext context, ContractCardState state) => CardRow(
        card: state.card,
        isBusy: state.isBusy,
        isEnabled: widget.isEnabled,
        disabledReason: widget.disabledReason,
        addPress: () => unawaited(_openForm(context)),
        removePress: () => context.read<ContractCardBloc>().add(const CardRemoved()),
      ),
    );
  }
}

/// Karta formasi oynasi. Muvaffaqiyatdan keyin o'zi yopiladi.
final class _CardSheet extends StatelessWidget {
  const _CardSheet({
    required this.phone,
    required this.number,
    required this.expiry,
    required this.phoneFocus,
    required this.numberFocus,
    required this.expiryFocus,
  });

  final TextEditingController phone;
  final TextEditingController number;
  final TextEditingController expiry;
  final FocusNode phoneFocus;
  final FocusNode numberFocus;
  final FocusNode expiryFocus;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContractCardBloc, ContractCardState>(
      listenWhen: (ContractCardState previous, ContractCardState current) =>
          current.revision != previous.revision,
      listener: (BuildContext context, ContractCardState state) => Navigator.of(context).pop(),
      builder: (BuildContext context, ContractCardState state) {
        final ContractCardBloc bloc = context.read<ContractCardBloc>();

        return Padding(
          padding: EdgeInsets.only(
            left: ScreenSize.h16,
            right: ScreenSize.h16,
            bottom: MediaQuery.viewInsetsOf(context).bottom + ScreenSize.h16,
          ),
          child: CardFormSection(
            card: state.card,
            issue: state.issue,
            isBusy: state.isBusy,
            isEnabled: true,
            disabledReason: '',
            phoneController: phone,
            numberController: number,
            expiryController: expiry,
            phoneFocus: phoneFocus,
            numberFocus: numberFocus,
            expiryFocus: expiryFocus,
            fieldChanged: ({String? phone, String? number, String? expiry}) => bloc.add(CardFieldChanged(phone: phone, number: number, expiry: expiry)),
            submitPress: () => bloc.add(const CardSubmitted()),
            removePress: () => bloc.add(const CardRemoved()),
          ),
        );
      },
    );
  }
}

/// Ekrandagi bir qatorlik xulosa.
///
/// O'z ramkasi yo'q — u daromad bo'limining ramkasi ichida turadi.
final class CardRow extends StatelessWidget {
  const CardRow({
    super.key,
    required this.card,
    required this.isBusy,
    required this.isEnabled,
    required this.disabledReason,
    required this.addPress,
    required this.removePress,
  });

  final ContractCard card;
  final bool isBusy;
  final bool isEnabled;
  final String disabledReason;
  final VoidCallback addPress;
  final VoidCallback removePress;

  /// `8600123412341234` → `•••• 1234`.
  String get _masked =>
      card.number.length < 4 ? card.number : "•••• ${card.number.substring(card.number.length - 4)}";

  @override
  Widget build(BuildContext context) {
    final bool hasCard = !card.isEmpty;
    final Color tone = isEnabled ? AppTheme.colors.blue : AppTheme.colors.grey1;

    return InkWell(
      onTap: isEnabled && !hasCard && !isBusy ? addPress : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h14, vertical: ScreenSize.h10),
        child: Row(
          children: <Widget>[
            Container(
              width: ScreenSize.h36,
              height: ScreenSize.h36,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(ScreenSize.r12),
              ),
              child: Icon(Icons.credit_card_outlined, size: ScreenSize.h18, color: tone),
            ),

            Gap(ScreenSize.w12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Karta aylanmasi",
                    style: AppTheme.data.textTheme.titleSmall?.copyWith(
                      color: isEnabled ? AppTheme.colors.blackSoft : AppTheme.colors.grey,
                    ),
                  ),
                  Gap(ScreenSize.h2),
                  Text(
                    hasCard ? _masked : (isEnabled ? "Biriktirilmagan" : disabledReason),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.data.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            Gap(ScreenSize.w8),
            if (isBusy)
              SizedBox(
                width: ScreenSize.h20,
                height: ScreenSize.h20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.colors.primary),
              )
            else if (hasCard)
              InkWell(
                onTap: removePress,
                borderRadius: BorderRadius.circular(ScreenSize.r10),
                child: Padding(
                  padding: EdgeInsets.all(ScreenSize.h4),
                  child: Icon(Icons.delete_outline, size: ScreenSize.h20, color: AppTheme.colors.red),
                ),
              )
            else if (isEnabled)
              Icon(Icons.add_rounded, size: ScreenSize.h20, color: AppTheme.colors.blue),
          ],
        ),
      ),
    );
  }
}

/// Qoralama hali yo'q — karta o'rniga sababi turadi.
final class CardPlaceholder extends StatelessWidget {
  const CardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(ScreenSize.h14, ScreenSize.h4, ScreenSize.h14, ScreenSize.h8),
    child: Text(
      "Karta birinchi tovar qo'shilgandan keyin biriktiriladi",
      style: AppTheme.data.textTheme.bodySmall,
    ),
  );
}

/// Karta blocini `contractId` bilan yaratadi.
BlocProvider<ContractCardBloc> cardBlocProvider({
  required int contractId,
  required int clientId,
  required ContractCard card,
  required Widget child,
}) => BlocProvider<ContractCardBloc>(
  create: (BuildContext context) =>
      getIt<ContractCardBloc>(param1: (contractId: contractId, clientId: clientId), param2: card),
  child: child,
);
