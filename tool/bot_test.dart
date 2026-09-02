// Botni tekshirish uchun bir martalik skript. Ilovaga kirmaydi.
// Ishga tushirish:  dart run tool/bot_test.dart

import 'dart:io';

import 'package:colloborator_v3/core/services/error_reporter.dart';
import 'package:colloborator_v3/core/services/telegram_error_reporter.dart';
import 'package:dio/dio.dart';

Future<void> main() async {
  final Map<String, String> env = _readEnv();
  final String token = env['BOT_TOKEN'] ?? '';
  final String chatId = env['BOT_CHAT_ID'] ?? '';

  stdout.writeln('BOT_TOKEN: ${token.isEmpty ? "YO'Q" : "bor (${token.length} belgi)"}');
  stdout.writeln('BOT_CHAT_ID: ${chatId.isEmpty ? "YO'Q" : chatId}');

  if (token.isEmpty || chatId.isEmpty) {
    stdout.writeln('\n.env to\'liq emas — to\'xtatildi.');
    return;
  }

  final Dio dio = Dio();

  // 1-qadam: token haqiqiymi?
  try {
    final Response<Map<String, dynamic>> me =
        await dio.get<Map<String, dynamic>>('https://api.telegram.org/bot$token/getMe');
    final Object? result = me.data?['result'];
    final String name = result is Map ? '${result['username']}' : '?';
    stdout.writeln('\n1) getMe — OK, bot: @$name');
  } catch (e) {
    stdout.writeln('\n1) getMe — XATO: ${_short(e)}');
    return;
  }

  // 2-qadam: guruhga xabar boradimi?
  try {
    await dio.post<void>(
      'https://api.telegram.org/bot$token/sendMessage',
      data: <String, Object>{'chat_id': chatId, 'text': 'To\'g\'ridan-to\'g\'ri sinov xabari'},
    );
    stdout.writeln('2) sendMessage — OK');
  } catch (e) {
    stdout.writeln('2) sendMessage — XATO: ${_short(e)}');
    return;
  }

  // 3-qadam: haqiqiy klass ishlaydimi?
  final TelegramErrorReporter reporter = TelegramErrorReporter(
    dio: Dio(),
    token: token,
    chatId: chatId,
    environment: 'sinov',
    now: DateTime.now,
  );

  reporter.report(
    ErrorReport(
      source: '/contracts',
      message: '500 · Server xatoligi',
      trace: StackTrace.current,
    ),
  );

  // 4-qadam: takror filtri ishlaydimi? Bu xabar YUBORILMASLIGI kerak.
  reporter.report(const ErrorReport(source: '/contracts', message: '500 · Server xatoligi'));

  await Future<void>.delayed(const Duration(seconds: 4));
  stdout.writeln('3) TelegramErrorReporter — yuborildi');
  stdout.writeln('\nGuruhda 2 ta xabar bo\'lishi kerak (3 ta emas — uchinchisi takror filtriga tushdi).');
}

Map<String, String> _readEnv() {
  final File file = File('.env');
  if (!file.existsSync()) return <String, String>{};

  final Map<String, String> result = <String, String>{};
  for (final String line in file.readAsLinesSync()) {
    final int i = line.indexOf('=');
    if (i <= 0 || line.trimLeft().startsWith('#')) continue;

    // `flutter_dotenv` ham shunday qiladi: atrofdagi qo'shtirnoqni oladi.
    String value = line.substring(i + 1).trim();
    if (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      value = value.substring(1, value.length - 1);
    }

    result[line.substring(0, i).trim()] = value;
  }

  return result;
}

String _short(Object e) {
  if (e is DioException) {
    return '${e.response?.statusCode ?? e.type} · ${e.response?.data ?? e.message}';
  }
  return e.toString();
}
