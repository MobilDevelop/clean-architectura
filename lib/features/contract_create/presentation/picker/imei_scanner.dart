import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// IMEI ro'yxati — **faqat o'qish uchun**.
///
/// Raqam qo'lda kiritilmaydi: qurilma yorlig'i suratga olinadi va server
/// o'sha qurilmaga tegishli barcha raqamlarni qaytaradi. Shuning uchun bu
/// yerda na kiritish maydoni, na bittalab o'chirish bor — ro'yxat butunligicha
/// almashadi. Qo'lda kiritish qoldirilsa, ekranda serverning javobi bilan
/// foydalanuvchi yozgani aralashib ketardi va qaysi biri to'g'ri ekani
/// bilinmasdi.
final class ImeiScanner extends StatelessWidget {
  const ImeiScanner({
    super.key,
    required this.imeis,
    required this.isScanning,
    required this.scanPress,
    required this.scanHint,
    this.errorText,
  });

  final List<String> imeis;

  final bool isScanning;

  /// `null` — hozir suratga olib bo'lmaydi. Sababi `scanHint` da yoziladi.
  final VoidCallback? scanPress;

  /// Tugma tagidagi izoh: nima bo'lishini yoki nega ishlamasligini aytadi.
  /// Matnni sahifa beradi — widget qaror qabul qilmaydi (6.7).
  final String scanHint;

  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final String? error = errorText;
    final VoidCallback? press = scanPress;
    final bool enabled = press != null && !isScanning;

    // O'chirilgan tugma rangsiz bo'ladi — aks holda u bosiladiganga o'xshaydi.
    final Color tone = enabled ? AppTheme.colors.blue : AppTheme.colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              "IMEI",
              style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: AppTheme.colors.textGraySoft),
            ),

            const Spacer(),
            if (imeis.isNotEmpty)
              Text(
                "${imeis.length} ta nusxa",
                style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.blue),
              ),
          ],
        ),

        Gap(ScreenSize.h8),
        InkWell(
          onTap: enabled ? press : null,
          borderRadius: BorderRadius.circular(ScreenSize.r14),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12, vertical: ScreenSize.h12),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(ScreenSize.r14),
              border: Border.all(color: tone.withValues(alpha: .28)),
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: ScreenSize.h24,
                  height: ScreenSize.h24,
                  child: isScanning
                      ? CircularProgressIndicator(strokeWidth: 2, color: tone)
                      : Icon(Icons.photo_camera_outlined, color: tone, size: ScreenSize.h22),
                ),

                Gap(ScreenSize.w12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        imeis.isEmpty ? "Yorliqni suratga olish" : "Qayta suratga olish",
                        style: AppTheme.data.textTheme.titleMedium?.copyWith(color: tone),
                      ),

                      Gap(ScreenSize.h2),
                      Text(
                        scanHint,
                        style: AppTheme.data.textTheme.bodySmall?.copyWith(
                          color: AppTheme.colors.textGraySoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        if (imeis.isNotEmpty) ...<Widget>[Gap(ScreenSize.h10), ...imeis.map(_row)],

        if (error != null) ...<Widget>[
          Gap(ScreenSize.h6),
          Text(error, style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.red)),
        ],
      ],
    );
  }

  Widget _row(String value) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: ScreenSize.h8),
    padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12, vertical: ScreenSize.h10),
    decoration: BoxDecoration(
      color: AppTheme.colors.backcolor,
      borderRadius: BorderRadius.circular(ScreenSize.r12),
      border: AppSurface.border(alpha: .6),
    ),
    child: Row(
      children: <Widget>[
        Icon(Icons.smartphone_outlined, size: ScreenSize.h18, color: AppTheme.colors.primary),

        Gap(ScreenSize.w10),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
          ),
        ),
      ],
    ),
  );
}
