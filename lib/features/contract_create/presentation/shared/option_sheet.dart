import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Xotiradagi kichik ro'yxatdan bitta element tanlash.
///
/// Katalog oynasidan farqi: bu yerda sahifalash ham, qidiruv ham yo'q —
/// ro'yxat allaqachon to'liq yuklangan.
Future<void> showOptionSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  required bool Function(T) isSelected,
  required ValueChanged<T> onPicked,
}) => showAppSheet(
  context: context,
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft)),
        Gap(ScreenSize.h12),

        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: ScreenSize.h12),
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final T item = options[index];
              final bool selected = isSelected(item);

              return Padding(
                padding: EdgeInsets.only(bottom: ScreenSize.h8),
                child: InkWell(
                  onTap: () {
                    onPicked(item);
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(ScreenSize.r14),
                  child: Container(
                    padding: EdgeInsets.all(ScreenSize.h14),
                    decoration: BoxDecoration(
                      // Tanlangani ajralib turadi — foydalanuvchi qayta
                      // kirganda nima tanlanganini ko'radi.
                      color: selected ? AppTheme.colors.primary.withValues(alpha: .08) : AppTheme.colors.backcolor,
                      borderRadius: BorderRadius.circular(ScreenSize.r14),
                      border: selected
                          ? Border.all(color: AppTheme.colors.primary)
                          : AppSurface.border(alpha: .5),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            labelOf(item),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.data.textTheme.bodyLarge?.copyWith(
                              color: selected ? AppTheme.colors.primary : AppTheme.colors.blackSoft,
                            ),
                          ),
                        ),

                        if (selected)
                          Icon(Icons.check_circle, size: ScreenSize.h20, color: AppTheme.colors.primary),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
);
