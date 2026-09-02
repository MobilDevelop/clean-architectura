import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:gap/gap.dart';

/// Ommaviy oferta matnini ochadi. Foydalanuvchi oxirigacha o'qigach tasdiqlay
/// oladi.
Future<void> showOfferSheet({required BuildContext context, required VoidCallback onAccepted}) =>
    showAppSheet(context: context, child: OfferSheet(onAccepted: onAccepted));

final class OfferSheet extends StatefulWidget {
  const OfferSheet({super.key, required this.onAccepted});

  final VoidCallback onAccepted;

  @override
  State<OfferSheet> createState() => _OfferSheetState();
}

final class _OfferSheetState extends State<OfferSheet> {
  final ScrollController _scroll = ScrollController();

  String _html = '';
  bool _isLoading = true;
  bool _isFailed = false;
  bool _isRead = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    unawaited(_load());
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final String content = await rootBundle.loadString(AppIcons.offerUz);
      if (!mounted) return;

      setState(() {
        _html = content;
        _isLoading = false;
      });

      // Matn ekranga to'liq sig'sa hech qachon scroll bo'lmaydi — flex'da
      // shu holatda tasdiqlash tugmasi abadiy o'chiq qolardi.
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkFits());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isFailed = true;
      });
    }
  }

  void _checkFits() {
    if (!mounted || !_scroll.hasClients) return;
    if (_scroll.position.maxScrollExtent <= 0) setState(() => _isRead = true);
  }

  void _onScroll() {
    if (_isRead || !_scroll.hasClients) return;

    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - ScreenSize.h8) {
      setState(() => _isRead = true);
    }
  }

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
                Expanded(
                  child: Text(
                    "Ommaviy oferta shartlari",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
                  ),
                ),
              ],
            ),

            Gap(ScreenSize.h12),
            Expanded(child: _body()),

            Gap(ScreenSize.h12),
            Text(
              _isRead ? "Shartlar bilan tanishdingiz" : "Tasdiqlash uchun matnni oxirigacha o'qing",
              textAlign: TextAlign.center,
              style: AppTheme.data.textTheme.bodyMedium?.copyWith(
                color: _isRead ? AppTheme.colors.primary : AppTheme.colors.grey,
              ),
            ),

            Gap(ScreenSize.h8),
            MainButton(
              text: "Roziman",
              color: _isRead ? null : AppTheme.colors.grey,
              onPressed: () {
                Navigator.of(context).pop();
                widget.onAccepted();
              },
            ),

            Gap(ScreenSize.h8),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_isLoading) return Center(child: CircularProgressIndicator(color: AppTheme.colors.primary));

    // Hujjat o'qilmasa tasdiqlash ham berilmaydi: o'qilmagan shartga rozilik
    // olish mumkin emas.
    if (_isFailed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Hujjat ochilmadi",
              style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
            ),

            Gap(ScreenSize.h12),
            SizedBox(
              width: ScreenSize.h160,
              child: MainButton(
                text: "Qayta urinish",
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _isFailed = false;
                  });
                  unawaited(_load());
                },
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        border: AppSurface.border(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        child: Scrollbar(
          controller: _scroll,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scroll,
            padding: EdgeInsets.all(ScreenSize.h14),
            child: HtmlWidget(
              _html,
              textStyle: AppTheme.data.textTheme.bodyLarge?.copyWith(
                color: AppTheme.colors.blackSoft,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
