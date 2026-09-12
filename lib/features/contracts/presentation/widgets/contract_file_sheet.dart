import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/signing_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:gap/gap.dart';

/// Shartnoma matnini ochadi va oxirigacha o'qilganini bildiradi.
Future<void> showContractFileSheet({
  required BuildContext context,
  required String html,
  required bool isRead,
  required VoidCallback onRead,
}) => showAppSheet(
  context: context,
  child: ContractFileSheet(html: html, isRead: isRead, onRead: onRead),
);

final class ContractFileSheet extends StatefulWidget {
  const ContractFileSheet({super.key, required this.html, required this.isRead, required this.onRead});

  final String html;
  final bool isRead;
  final VoidCallback onRead;

  @override
  State<ContractFileSheet> createState() => _ContractFileSheetState();
}

final class _ContractFileSheetState extends State<ContractFileSheet> {
  final ScrollController _scroll = ScrollController();

  late bool _isRead = widget.isRead;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);

    // Matn ekranga to'liq sig'sa hech qachon scroll bo'lmaydi — o'shanda
    // tugma abadiy o'chiq qolardi (oferta oynasidagi bilan bir xil qoida).
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFits());
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _checkFits() {
    if (!mounted || !_scroll.hasClients) return;
    if (_scroll.position.maxScrollExtent <= 0) _markRead();
  }

  void _onScroll() {
    if (_isRead || !_scroll.hasClients) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - ScreenSize.h8) _markRead();
  }

  void _markRead() {
    if (_isRead) return;

    setState(() => _isRead = true);
    widget.onRead();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .85,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
        child: Column(
          children: <Widget>[
            Text(
              SigningText.documentTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
            ),

            Gap(ScreenSize.h12),
            Expanded(
              child: Container(
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
                        widget.html,
                        // `buildAsync` ning sukut qiymati `html.length > 10000`.
                        // Async rejimda kutubxona har ochilishda `compute()` bilan
                        // izolyat ochadi va **o'zining** yuklanish belgisini
                        // chizadi — oferta oynasida aynan shu muammo bo'lgan.
                        buildAsync: false,
                        enableCaching: true,
                        textStyle: AppTheme.data.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.colors.blackSoft,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Gap(ScreenSize.h12),
            Text(
              _isRead ? SigningText.documentRead : SigningText.documentUnread,
              textAlign: TextAlign.center,
              style: AppTheme.data.textTheme.bodyMedium?.copyWith(
                color: _isRead ? AppTheme.colors.primary : AppTheme.colors.grey,
              ),
            ),

            Gap(ScreenSize.h8),
          ],
        ),
      ),
    );
  }
}
