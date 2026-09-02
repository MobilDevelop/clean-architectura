import 'dart:async';

import 'package:colloborator_v3/core/services/error_reporter.dart';
import 'package:dio/dio.dart';

final class TelegramErrorReporter implements ErrorReporter {
  TelegramErrorReporter({
    required this.dio,
    required this.token,
    required this.chatId,
    required this.environment,
    required this.now,
  });


  final Dio dio;

  final String token;
  final String chatId;

  /// Xabar sarlavhasida ko'rinadi — sinov xatolari haqiqiylari bilan aralashmasin.
  final String environment;

  /// Vaqt tashqaridan beriladi, shuning uchun takror filtrini test qilish mumkin.
  final DateTime Function() now;

  /// Yuborilgan xabarlar: `signature` → oxirgi yuborilgan payt.
  final Map<String, DateTime> _sent = <String, DateTime>{};

  /// Bir xil xato shu muddat ichida takror yuborilmaydi.
  static const Duration _repeatWindow = Duration(minutes: 10);

  /// Telegram chegarasi 4096 belgi — zaxira bilan qisqartiramiz.
  static const int _maxLength = 3500;

  /// Trace'dan shuncha qator olinadi — qolgani baribir o'qilmaydi.
  static const int _traceLines = 10;

  /// Xotira cheksiz o'smasligi uchun kuzatiladigan xatolar chegarasi.
  static const int _maxTracked = 100;

  @override
  void report(ErrorReport report) {
    // Bot sozlanmagan (masalan yangi dasturchining `.env` i to'liq emas) —
    // bu ilova ishlashiga to'sqinlik qilmasligi kerak.
    if (token.isEmpty || chatId.isEmpty) return;

    final DateTime moment = now();
    final DateTime? last = _sent[report.signature];

    // Bitta buzuq endpoint guruhni yuzlab bir xil xabar bilan to'ldirmasin.
    if (last != null && moment.difference(last) < _repeatWindow) return;

    _sent[report.signature] = moment;
    _forget(moment);

    unawaited(_send(_compose(report)));
  }

  /// Eskirgan yozuvlarni tashlab yuboradi.
  void _forget(DateTime moment) {
    if (_sent.length <= _maxTracked) return;

    _sent.removeWhere((_, DateTime at) => moment.difference(at) > _repeatWindow);
  }

  String _compose(ErrorReport report) {
    final StringBuffer text = StringBuffer()
      ..writeln('🔴 Collaborator v3 · $environment')
      ..writeln()
      ..writeln('📍 ${report.source}')
      ..writeln('📝 ${report.message}');

    final StackTrace? trace = report.trace;
    if (trace != null) {
      final Iterable<String> lines = trace.toString().split('\n').take(_traceLines);

      text
        ..writeln()
        ..writeln(lines.join('\n'));
    }

    final String result = text.toString();

    return result.length <= _maxLength ? result : '${result.substring(0, _maxLength)}…';
  }

  Future<void> _send(String text) async {
    try {
      await dio.post<void>('https://api.telegram.org/bot$token/sendMessage',data: <String, Object>{'chat_id': chatId, 'text': text});
    } catch (_) {
      // Nega jim: xato haqidagi xabarning o'zi ilovani yiqitmasligi kerak.
      // Telegram javob bermasa yoki bot guruhdan chiqarilgan bo'lsa, shu yerda tugaydi.
    }
  }
}
