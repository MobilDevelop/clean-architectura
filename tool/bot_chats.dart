// Bot ko'rgan chatlarni ro'yxatlaydi. Token ekranga chiqarilmaydi.
// Ishga tushirish:  dart run tool/bot_chats.dart

import 'dart:io';
import 'package:dio/dio.dart';

Future<void> main() async {
  final File file = File('.env');
  String token = '';

  for (final String line in file.readAsLinesSync()) {
    if (!line.trim().startsWith('BOT_TOKEN')) continue;

    token = line.substring(line.indexOf('=') + 1).trim();
    if (token.length >= 2 && (token.startsWith('"') || token.startsWith("'"))) {
      token = token.substring(1, token.length - 1);
    }
  }

  if (token.isEmpty) {
    stdout.writeln("BOT_TOKEN topilmadi");
    return;
  }

  final Response<Map<String, dynamic>> res = await Dio()
      .get<Map<String, dynamic>>('https://api.telegram.org/bot$token/getUpdates');

  final Object? updates = res.data?['result'];
  if (updates is! List || updates.isEmpty) {
    stdout.writeln("Bot hali hech qanday xabar ko'rmagan.");
    stdout.writeln("Guruhga /start deb yozing va shu skriptni qayta yurgizing.");
    return;
  }

  stdout.writeln('Bot ko\'rgan chatlar:\n');

  final Set<String> seen = <String>{};
  for (final Object? update in updates) {
    if (update is! Map) continue;

    final Object? message = update['message'] ?? update['my_chat_member'] ?? update['channel_post'];
    if (message is! Map) continue;

    final Object? chat = message['chat'];
    if (chat is! Map) continue;

    final String id = '${chat['id']}';
    if (!seen.add(id)) continue;

    final String type = '${chat['type']}';
    final String title = '${chat['title'] ?? chat['username'] ?? chat['first_name'] ?? ''}';

    stdout.writeln('  id: $id');
    stdout.writeln('  turi: $type');
    stdout.writeln('  nomi: $title');
    stdout.writeln('  ${type == 'group' || type == 'supergroup' ? '← BOT_CHAT_ID uchun shuni oling' : ''}\n');
  }
}
