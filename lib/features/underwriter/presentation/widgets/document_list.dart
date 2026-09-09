import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_file.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Bo'limga biriktirilgan hujjatlar va qo'shish tugmasi.
final class DocumentList extends StatelessWidget {
  const DocumentList({
    super.key,
    required this.files,
    required this.isFull,
    required this.addTitle,
    required this.errorText,
    required this.addPress,
    required this.removePress,
  });

  final List<UnderwriterFile> files;

  /// Chegaraga yetilganmi. Widget uni hisoblamaydi (6.7).
  final bool isFull;

  final String addTitle;

  /// Fayl qo'shilmaganining sababi yoki hujjat yo'qligi haqidagi kamchilik.
  final String? errorText;

  final VoidCallback addPress;
  final ValueChanged<int> removePress;

  @override
  Widget build(BuildContext context) {
    final String? error = errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < files.length; i++) _row(files[i], i),

        // Chegaraga yetganda tugma o'rniga sabab turadi: yo'qolib qolgan
        // tugma foydalanuvchiga hech nima aytmaydi (5.8).
        if (isFull) _limitNote() else _addButton(),

        if (error != null) ...<Widget>[
          Gap(ScreenSize.h8),
          Text(error, style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.red)),
        ],
      ],
    );
  }

  Widget _limitNote() => Padding(
    padding: EdgeInsets.symmetric(vertical: ScreenSize.h8),
    child: Row(
      children: <Widget>[
        Icon(Icons.info_outline_rounded, size: ScreenSize.h16, color: AppTheme.colors.grey),

        Gap(ScreenSize.w6),
        Expanded(
          child: Text(
            "Ko'pi bilan ${UnderwriterFileRule.maxCount} ta hujjat — o'chirib boshqasini qo'shing",
            style: AppTheme.data.textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );

  Widget _row(UnderwriterFile file, int index) => Container(
    margin: EdgeInsets.only(bottom: ScreenSize.h8),
    padding: EdgeInsets.all(ScreenSize.h10),
    decoration: BoxDecoration(
      color: AppTheme.colors.backcolor,
      borderRadius: BorderRadius.circular(ScreenSize.r14),
    ),
    child: Row(
      children: <Widget>[
        Icon(
          file.isUploaded ? Icons.cloud_done_outlined : Icons.insert_drive_file_outlined,
          size: ScreenSize.h20,
          color: file.isUploaded ? AppTheme.colors.primary : AppTheme.colors.blue,
        ),

        Gap(ScreenSize.w10),
        Expanded(
          child: Text(
            // Serverdan kelgan hujjatning nomi yo'q — kaliti esa tasodifiy
            // satr va foydalanuvchiga hech nima aytmaydi, shuning uchun
            // tartib raqami ko'rsatiladi.
            file.name.isEmpty ? "Hujjat ${index + 1}" : file.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
          ),
        ),

        Gap(ScreenSize.w8),
        InkWell(
          onTap: () => removePress(index),
          borderRadius: BorderRadius.circular(ScreenSize.r10),
          child: Padding(
            padding: EdgeInsets.all(ScreenSize.h4),
            child: Icon(Icons.close_rounded, size: ScreenSize.h18, color: AppTheme.colors.red),
          ),
        ),
      ],
    ),
  );

  Widget _addButton() => InkWell(
    onTap: addPress,
    borderRadius: BorderRadius.circular(ScreenSize.r14),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: ScreenSize.h14),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(ScreenSize.r14),
        border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.attach_file_rounded, size: ScreenSize.h18, color: AppTheme.colors.primary),
          Gap(ScreenSize.w6),
          Flexible(
            child: Text(
              addTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.primary),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Hujjat yo'qligini bildiruvchi bo'sh holat — hech qanday chegara yo'q joyda.
final class DocumentHint extends StatelessWidget {
  const DocumentHint({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(ScreenSize.h12),
    decoration: BoxDecoration(
      color: AppTheme.colors.backcolor,
      borderRadius: BorderRadius.circular(ScreenSize.r14),
      border: AppSurface.border(alpha: .4),
    ),
    child: Text(text, style: AppTheme.data.textTheme.bodySmall),
  );
}
