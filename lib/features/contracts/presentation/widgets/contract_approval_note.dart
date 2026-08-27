import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';

/// Ekranda vaqt shu ko'rinishda yoziladi. Backend formati emas — bu
/// foydalanuvchi o'qiydigan shakl, shuning uchun presentationda turadi.
final DateFormat _dateTime = DateFormat('dd.MM.yyyy, HH:mm');

/// Limit oshganda ruxsat talab qilinishi haqidagi eslatma.
final class ContractApprovalNote extends StatelessWidget {
  const ContractApprovalNote({super.key, required this.contract});

  final ContractInfo contract;

  String get _sender => contract.sentUserFullname.isNotEmpty ? contract.sentUserFullname : contract.sentPartnerFullname;

  @override
  Widget build(BuildContext context) {
    final Color color = AppTheme.colors.yellow;

    // Nega mahalliy o'zgaruvchi: `contract.sentAt` — boshqa kutubxonadagi
    // ochiq maydon, Dart uni `null` tekshiruvidan keyin ham ko'tarmaydi.
    // Mahalliy nusxa `!` operatorisiz ishlashga imkon beradi (12-bo'lim).
    final DateTime? sentAt = contract.sentAt;
    final DateTime? confirmedAt = contract.directorConfirmedAt;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: ScreenSize.h10),
      padding: EdgeInsets.all(ScreenSize.h10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(ScreenSize.r14),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SvgPicture.asset(
                AppIcons.warning,
                height: ScreenSize.h16,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),

              Gap(ScreenSize.w8),
              Expanded(
                child: Text(
                  "Shartnoma limiti oshgan — ruxsat talab qilinadi",
                  style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: color),
                ),
              ),
            ],
          ),

          if (_sender.isNotEmpty) _row(label: "Yuborgan", value: _sender),
          if (sentAt != null) _row(label: "Yuborilgan vaqti", value: _dateTime.format(sentAt)),
          if (confirmedAt != null) _row(label: "Direktor tasdiqlagan", value: _dateTime.format(confirmedAt)),
        ],
      ),
    );
  }

  Widget _row({required String label, required String value}) => Padding(
    padding: EdgeInsets.only(top: ScreenSize.h6),
    child: Row(
      children: <Widget>[
        Text(label, style: AppTheme.data.textTheme.labelMedium),

        const Spacer(),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: AppTheme.colors.blackSoft),
          ),
        ),
      ],
    ),
  );
}
