import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ro'yxatni tortib yangilash.
///
/// Shartnomalar va chiqim tovarlar ro'yxatlari ishlatadi (1.2).
///
/// Nega alohida: `RefreshIndicator` ning `onRefresh` i **yuklash tugagunicha
/// kutadigan** `Future` talab qiladi. Bloc bilan bu shart o'z-o'zidan
/// bajarilmaydi — event yuborilgach `Future` darhol tugasa, indikator
/// aylanmasdan yo'qoladi va foydalanuvchi yangilanish bo'ldimi-yo'qmi
/// bilmaydi.
final class PullRefresh<B extends StateStreamable<S>, S> extends StatelessWidget {
  const PullRefresh({
    super.key,
    required this.isLoading,
    required this.refreshPress,
    required this.child,
    this.edgeOffset = 0,
  });

  /// Berilgan holat yuklanish holatidami.
  final bool Function(S state) isLoading;

  /// Yangilash eventini yuboradi.
  final VoidCallback refreshPress;

  /// Indikator suzuvchi sarlavha ostida qolib ketmasligi uchun.
  final double edgeOffset;

  final Widget child;

  /// Yuklash tugashini kutadi.
  ///
  /// Javob umuman kelmasa indikator abadiy aylanib qolmasligi kerak —
  /// shuning uchun chegara qo'yilgan. Xatoning o'zi `FailureView` da
  /// ko'rsatiladi, bu yerda faqat indikator to'xtaydi.
  static const Duration _limit = Duration(seconds: 30);

  Future<void> _refresh(BuildContext context) async {
    final B bloc = context.read<B>();

    refreshPress();

    await bloc.stream.firstWhere((S state) => !isLoading(state)).timeout(
      _limit,
      onTimeout: () => bloc.state,
    );
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () => _refresh(context),
    edgeOffset: edgeOffset,
    color: AppTheme.colors.primary,
    backgroundColor: AppTheme.colors.white,
    child: child,
  );
}
