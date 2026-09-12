import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';
import 'package:colloborator_v3/features/outputs/presentation/list/output_product_row.dart';
import 'package:colloborator_v3/features/outputs/presentation/shared/output_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Chiqimga tayyor shartnoma. Bosilganda tovarlari ochiladi.
///
/// Widget qaror qabul qilmaydi (6.7): nima ochiq, tovarlar yuklanganmi —
/// hammasini sahifa aytadi.
final class OutputCard extends StatelessWidget {
  const OutputCard({
    super.key,
    required this.contract,
    required this.isOpen,
    required this.isLoading,
    required this.products,
    required this.selected,
    required this.isReturning,
    required this.onTap,
    required this.onProductTap,
    required this.onRelease,
    required this.onReturn,
  });

  final OutputContract contract;
  final bool isOpen;

  /// Shu qatorning tovarlari yuklanmoqda.
  final bool isLoading;

  /// O'qilgan tovarlar. `null` — hali o'qilmagan.
  final List<OutputProduct>? products;

  /// Qaytarish uchun belgilangan tovarlar.
  final Set<int> selected;

  final bool isReturning;

  final VoidCallback onTap;
  final ValueChanged<int> onProductTap;
  final VoidCallback onRelease;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: ScreenSize.h12, right: ScreenSize.h12, bottom: ScreenSize.h12),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        border: AppSurface.border(),
        boxShadow: AppShadow.card(),
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(ScreenSize.r20),
            child: Padding(padding: EdgeInsets.all(ScreenSize.h14), child: _header()),
          ),

          if (isOpen)
            Padding(
              padding: EdgeInsets.fromLTRB(ScreenSize.h14, 0, ScreenSize.h14, ScreenSize.h14),
              child: _body(),
            ),
        ],
      ),
    );
  }

  Widget _header() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          // Ism kesilmaydi: kesilgan ism xodimga mijozni tanishga xalaqit
          // beradi.
          Expanded(
            child: Text(
              contract.clientName.isEmpty ? "Mijoz" : contract.clientName,
              style: AppTheme.data.textTheme.headlineLarge?.copyWith(color: AppTheme.colors.black),
            ),
          ),

          Gap(ScreenSize.w8),
          Icon(
            isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
            size: ScreenSize.h22,
            color: AppTheme.colors.grey,
          ),
        ],
      ),

      Gap(ScreenSize.h4),
      Text("№ ${contract.id} · ${contract.createdAt}", style: AppTheme.data.textTheme.bodyMedium),

      if (contract.phone.isNotEmpty) ...<Widget>[
        Gap(ScreenSize.h2),
        Text(PhoneFormatter.mask(contract.phone), style: AppTheme.data.textTheme.bodyMedium),
      ],

      Gap(ScreenSize.h10),
      // Summa va holat bir qatorga sig'sa — chetlarga tarqaladi, sig'masa
      // holat o'z qatoriga tushadi. `Row` da uzun holat nomi («Faktura
      // tasdiqlangan») qatordan toshib ketardi va summa uch nuqtaga aylanardi
      // — xodim ikkalasini ham o'qiy olmasdi.
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: ScreenSize.w10,
        runSpacing: ScreenSize.h6,
        children: <Widget>[
          Text(
            Money.withUnit(contract.totalPrice),
            style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.primary),
          ),

          _statusChip(),
        ],
      ),
    ],
  );

  Widget _statusChip() => Container(
    padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h4),
    decoration: BoxDecoration(
      color: AppTheme.colors.blue.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(ScreenSize.r12),
      border: Border.all(color: AppTheme.colors.blue.withValues(alpha: .35)),
    ),
    child: Text(
      OutputText.status(contract.status),
      style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.blue),
    ),
  );

  Widget _body() {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: ScreenSize.h16),
        child: Center(child: CircularProgressIndicator(color: AppTheme.colors.primary)),
      );
    }

    final List<OutputProduct> list = products ?? const <OutputProduct>[];

    // Imzolangan shartnomada tovar chiqimga beriladi, qolganida esa faqat
    // qaytarish qoladi — belgilash ham shu holatda ochiladi.
    final bool canReturn = !contract.canRelease;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Bo'sh ro'yxat ham javob: qator ochilib hech nima ko'rinmasa,
        // yuklanmadimi yoki tovar yo'qmi — bilinmasdi (5.8).
        if (list.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: ScreenSize.h8),
            child: Text(
              OutputText.noProducts,
              textAlign: TextAlign.center,
              style: AppTheme.data.textTheme.bodyMedium,
            ),
          )
        else ...<Widget>[
          Text(
            "${OutputText.products} · ${list.length}",
            style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.grey),
          ),

          for (final OutputProduct product in list)
            OutputProductRow(
              product: product,
              isSelectable: canReturn,
              isSelected: selected.contains(product.id),
              onTap: () => onProductTap(product.id),
            ),
        ],

        // Amal tugmasi tovarlar ro'yxatiga bog'liq emas: `for_cancelled`
        // so'rovi imzolangan shartnomaga bo'sh ro'yxat qaytarsa, chiqim
        // berish tugmasi umuman chizilmay, oqim berkilib qolardi.
        Gap(ScreenSize.h12),
        if (contract.canRelease)
          MainButton(text: OutputText.release, leftIcon: AppIcons.done, onPressed: onRelease)
        else
          MainButton(
            text: OutputText.returnAction(selected.length),
            showLoading: isReturning,
            // Tanlovsiz tugma bosilmaydi: bo'sh so'rov shartnomani
            // o'zgartirmaydi, lekin javobi muvaffaqiyat bo'lgani uchun ekran
            // «qaytarildi» deb ko'rsatardi (5.8).
            color: selected.isEmpty ? AppTheme.colors.grey : AppTheme.colors.red,
            onPressed: onReturn,
          ),
      ],
    );
  }
}
