import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/info_tile.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/phone_number.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customer_avatar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Mijozning to'liq ma'lumoti. Faqat ko'rsatadi — o'zgartirish tahrirlash
/// ekranida.
Future<void> showCustomerDetails({required BuildContext context, required CustomerInfo info}) =>
    showAppSheet(context: context, child: CustomerDetailsSheet(info: info));

final class CustomerDetailsSheet extends StatelessWidget {
  const CustomerDetailsSheet({super.key, required this.info});

  final CustomerInfo info;

  /// Bo'sh maydon yashirilmaydi — agent nima yetishmayotganini ko'rishi kerak.
  static const String _empty = "Ko'rsatilmagan";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .8,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                CustomerAvatar(fullName: info.fullName),

                Gap(ScreenSize.w12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        info.fullName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
                      ),

                      Gap(ScreenSize.h2),
                      Text(
                        info.passportType ? "ID karta" : "Biometrik pasport",
                        style: AppTheme.data.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Gap(ScreenSize.h16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: ScreenSize.h16),
                children: <Widget>[
                  _tile(AppIcons.passport, "Pasport", info.passportNumber),
                  _tile(AppIcons.calendar, "Tug'ilgan sana", info.birthDay),
                  _tile(AppIcons.person, "INPS", info.inps),
                  _tile(AppIcons.calendar, "Berilgan", info.passportGiven),
                  _tile(AppIcons.calendar, "Amal qiladi", info.passportExpire),
                  _tile(AppIcons.workplace, "Ish joyi", info.workplace.name),
                  _tile(AppIcons.info, "Faoliyat turi", info.workplace.category.name),
                  _tile(AppIcons.info, "Manzil", info.mainAddress),
                  _tile(AppIcons.info, "Ko'cha", info.street),
                  _tile(AppIcons.info, "Uy raqami", info.houseNumber),

                  ...info.phones.map(
                    (PhoneNumber phone) =>
                        _tile(AppIcons.phone, phone.isMain ? "Shaxsiy raqam" : _label(phone), phone.phone),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label(PhoneNumber phone) => phone.comment.isEmpty ? "Qo'shimcha raqam" : phone.comment;

  Widget _tile(String icon, String label, String value) => Padding(
    padding: EdgeInsets.only(bottom: ScreenSize.h8),
    child: InfoTile(icon: icon, label: label, value: value.isEmpty ? _empty : value, isEmpty: value.isEmpty),
  );
}
