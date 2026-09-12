import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/drawer/app_drawer.dart';
import 'package:colloborator_v3/core/widgets/drawer/app_drawer_scope.dart';
import 'package:colloborator_v3/features/main/presentation/widgets/bottom_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const List<({String icon, String label})> _tabs = <({String icon, String label})>[
  (icon: AppIcons.customers, label: "Mijozlar"),
  (icon: AppIcons.contract, label: "Shartnomalar"),
  (icon: AppIcons.output, label: "Chiqim tovar"),
  (icon: AppIcons.file, label: "Fakturalar"),
];

final class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<MainPage> createState() => _MainPageState();
}

final class _MainPageState extends State<MainPage> {
  /// Menyu shu `Scaffold` da turadi — shuning uchun u pastki panel ustiga
  /// ham chiqadi. Ekranlar uni `AppDrawerScope` orqali ochadi.
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      drawer: const AppDrawer(),
      backgroundColor: AppTheme.colors.backcolor,
      body: AppDrawerScope(
        open: () => _scaffold.currentState?.openDrawer(),
        child: widget.shell,
      ),
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
                    isSelect: widget.shell.currentIndex == index,
                    press: () => widget.shell.goBranch(index, initialLocation: widget.shell.currentIndex == index),
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
