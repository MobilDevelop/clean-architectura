import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/main/presentation/widgets/bottom_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const List<({String icon, String label})> _tabs = <({String icon, String label})>[
  (icon: AppIcons.customers, label: "Mijozlar"),
  (icon: AppIcons.contract, label: "Shartnomalar"),
  (icon: AppIcons.output, label: "Chiqim tovar"),
  (icon: AppIcons.file, label: "Fakturalar"),
];

final class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.backcolor,
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          border: Border(top: BorderSide(color: AppSurface.line())),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Container(
            height: ScreenSize.h80,
            padding: EdgeInsets.only(bottom: ScreenSize.h10,top: ScreenSize.h1),
            child: Row(
              children: List<Widget>.generate(
                _tabs.length,
                (int index) => Expanded(
                  child: BottomItem(
                    icon: _tabs[index].icon,
                    label: _tabs[index].label,
                    isSelect: shell.currentIndex == index,
                    press: () => shell.goBranch(index, initialLocation: shell.currentIndex == index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
