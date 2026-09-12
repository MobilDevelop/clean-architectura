import 'dart:async';

import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Kod muddatini sanaydi va tugagach `onExpired` ni chaqiradi.
///
/// Nega alohida widget: taymer faqat shu matnni qayta chizadi. Bloc ichida
/// bo'lsa har soniyada butun oyna qayta qurilardi, va vaqt bloc'ga kirib
/// kelib uni sinash uchun soatni almashtirish kerak bo'lardi (9.4).
final class SmsCountdown extends StatefulWidget {
  const SmsCountdown({super.key, required this.expiresAt, required this.onExpired});

  final DateTime expiresAt;
  final VoidCallback onExpired;

  @override
  State<SmsCountdown> createState() => _SmsCountdownState();
}

final class _SmsCountdownState extends State<SmsCountdown> {
  Timer? _timer;
  late Duration _left = _remaining();

  @override
  void initState() {
    super.initState();

    if (_left > Duration.zero) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _remaining() {
    final Duration left = widget.expiresAt.difference(DateTime.now());

    return left.isNegative ? Duration.zero : left;
  }

  void _tick() {
    if (!mounted) return;

    final Duration left = _remaining();
    setState(() => _left = left);

    if (left > Duration.zero) return;

    _timer?.cancel();
    widget.onExpired();
  }

  @override
  Widget build(BuildContext context) {
    final String minutes = _left.inMinutes.toString().padLeft(2, '0');
    final String seconds = (_left.inSeconds % 60).toString().padLeft(2, '0');

    return Text(
      '$minutes:$seconds',
      style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.black),
    );
  }
}
