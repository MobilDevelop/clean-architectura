import 'dart:io';
import 'dart:typed_data';

import 'package:colloborator_v3/core/network/interceptors/http_log_interceptor.dart';
import 'package:colloborator_v3/core/widgets/http_log/http_log_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Jurnaldagi har bir so'rov yakunlangan holatga kelishini qulflaydi:
/// ishonch_setapp'dagi asl nusxada xabarsiz `DioException` yozuvni abadiy
/// «yuborilmoqda» da qoldirardi.
void main() {
  DateTime now = DateTime(2026, 9, 15, 10);
  late HttpLog log;

  setUp(() {
    now = DateTime(2026, 9, 15, 10);
    log = HttpLog(now: () => now);
  });

  Dio dioAnswering(Future<ResponseBody> Function(RequestOptions options) answer) {
    return Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = _FakeAdapter(answer)
      ..interceptors.add(HttpLogInterceptor(log));
  }

  ResponseBody json(String body, int statusCode) => ResponseBody.fromString(
        body,
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  test('javob kelsa — status, tana va davomiylik yoziladi', () async {
    final Dio dio = dioAnswering((_) async {
      now = now.add(const Duration(milliseconds: 120));
      return json('{"ok":true}', 200);
    });

    await dio.post<Object?>('/loans', data: {'count': 1});

    final HttpLogEntry entry = log.entries.single;
    expect(entry.method, 'POST');
    expect(entry.url.toString(), 'https://api.test/loans');
    expect(entry.requestBody, {'count': 1});
    expect(entry.isPending, isFalse);
    expect(entry.hasError, isFalse);
    expect(entry.statusCode, 200);
    expect(entry.responseBody, {'ok': true});
    expect(entry.duration, const Duration(milliseconds: 120));
  });

  test('4xx javob — xato sifatida, server tanasi bilan', () async {
    final Dio dio = dioAnswering((_) async => json('{"message":"bad"}', 422));

    await expectLater(dio.get<Object?>('/client-search'), throwsA(isA<DioException>()));

    final HttpLogEntry entry = log.entries.single;
    expect(entry.isPending, isFalse);
    expect(entry.hasError, isTrue);
    expect(entry.statusCode, 422);
    expect(entry.responseBody, {'message': 'bad'});
  });

  test('javobsiz va xabarsiz xato ham yozuvni yakunlaydi', () async {
    final Dio dio = dioAnswering((_) async => throw const SocketException('failed'));

    await expectLater(dio.get<Object?>('/loans'), throwsA(isA<DioException>()));

    final HttpLogEntry entry = log.entries.single;
    expect(entry.isPending, isFalse);
    expect(entry.hasError, isTrue);
    expect(entry.statusCode, isNull);
  });

  test('chegaradan oshsa eng eskisi tushib qoladi, eng yangisi birinchi', () {
    for (int i = 0; i <= HttpLog.capacity; i++) {
      log.start(method: 'GET', url: Uri.parse('https://api.test/$i'), headers: const {});
    }

    expect(log.entries, hasLength(HttpLog.capacity));
    expect(log.entries.first.url.path, '/${HttpLog.capacity}');
    expect(log.entries.last.url.path, '/1');
  });

  group('HttpLogFormat', () {
    test('baytlar chiqarilmaydi, faqat hajmi', () {
      expect(HttpLogFormat.body(Uint8List(2048)), '<2048 bayt>');
    });

    test('JSON chekinish bilan chiqariladi', () {
      expect(HttpLogFormat.body({'a': 1}), '{\n  "a": 1\n}');
    });

    test("JSON ga kodlab bo'lmaydigan qiymat otilmaydi — matnga aylanadi", () {
      expect(HttpLogFormat.body({'at': DateTime(2026, 9, 15)}), contains('2026-09-15'));
    });
  });
}

final class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._answer);

  final Future<ResponseBody> Function(RequestOptions options) _answer;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) =>
      _answer(options);

  @override
  void close({bool force = false}) {}
}
