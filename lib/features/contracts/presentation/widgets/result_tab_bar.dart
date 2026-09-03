import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// Skoring / MIB / KATM tablari.
final class ResultTabBar extends StatelessWidget {
  const ResultTabBar({super.key, required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenSize.h50,
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h4, vertical: ScreenSize.h4),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        border: Border(bottom: BorderSide(color: AppSurface.line())),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenSize.r12),
          color: AppTheme.colors.primary,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppTheme.colors.white,
        unselectedLabelColor: AppTheme.colors.grey,
        labelStyle: AppTheme.data.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTheme.data.textTheme.titleMedium,
        tabs: const <Widget>[Tab(text: "Skoring"), Tab(text: "MIB"), Tab(text: "KATM")],
      ),
    );
  }
}
