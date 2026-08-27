import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Ekranga sig'adigan taxminiy karta soni.
const int _cardCount = 5;

/// Pulsning bir tomonga borish vaqti.
const Duration _pulse = Duration(milliseconds: 900);

/// Shartnomalar yuklanayotgandagi skelet.
final class ContractsSkeleton extends StatefulWidget {
  const ContractsSkeleton({super.key});

  @override
  State<ContractsSkeleton> createState() => _ContractsSkeletonState();
}

final class _ContractsSkeletonState extends State<ContractsSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _pulse);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Tizimda "harakatni kamaytirish" yoqilgan bo'lsa, cheksiz puls
    // foydalanuvchiga noqulaylik tug'diradi.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 1;
      return;
    }

    if (!_controller.isAnimating) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: .45, end: 1).animate(_controller),
      child: Column(
        children: List<Widget>.generate(_cardCount, (int index) => const _SkeletonCard()),
      ),
    );
  }
}

final class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: ScreenSize.h12, right: ScreenSize.h12, bottom: ScreenSize.h12),
      padding: EdgeInsets.all(ScreenSize.h14),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        border: AppSurface.border(),
        boxShadow: AppShadow.card(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Block(height: ScreenSize.h14, width: ScreenSize.w180, radius: ScreenSize.r6),

          Gap(ScreenSize.h8),
          _Block(height: ScreenSize.h10, width: ScreenSize.w130, radius: ScreenSize.r6),

          Gap(ScreenSize.h14),
          Row(
            children: <Widget>[
              _Block(height: ScreenSize.h24, width: ScreenSize.w140, radius: ScreenSize.r12),

              const Spacer(),
              _Block(height: ScreenSize.h24, width: ScreenSize.w70, radius: ScreenSize.r12),
            ],
          ),
        ],
      ),
    );
  }
}

final class _Block extends StatelessWidget {
  const _Block({required this.height, required this.width, required this.radius});

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.colors.grey1.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
