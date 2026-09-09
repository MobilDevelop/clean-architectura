import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// Shartnoma ekranining uch tabi.
///
/// Tanlangan tab to'ldirilgan rang bilan ajraladi — kulrangdan kulrangga
/// o'tish qaysi tab ochiqligini zo'rg'a ko'rsatardi. Yorliqdagi son esa
/// tabni ochmasdan ichida nima borligini aytadi.
final class ContractTabBar extends StatelessWidget {
  const ContractTabBar({super.key, required this.productCount, required this.guarantorCount});

  final int productCount;
  final int guarantorCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenSize.h46,
      margin: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
      padding: EdgeInsets.all(ScreenSize.h4),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r16),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        splashBorderRadius: BorderRadius.circular(ScreenSize.r12),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenSize.r12),
          gradient: LinearGradient(colors: <Color>[AppTheme.colors.primary, AppTheme.colors.primarySoft]),
        ),
        labelColor: AppTheme.colors.white,
        unselectedLabelColor: AppTheme.colors.grey,
        labelStyle: AppTheme.data.textTheme.titleSmall,
        unselectedLabelStyle: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
        tabs: <Widget>[
          const Tab(text: "Shartnoma"),
          Tab(text: _label("Tovarlar", productCount)),
          Tab(text: _label("Kafillar", guarantorCount)),
        ],
      ),
    );
  }

  String _label(String title, int count) => count == 0 ? title : "$title · $count";
}
