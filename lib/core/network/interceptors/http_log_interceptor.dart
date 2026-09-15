import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Bitta HTTP so'rov va unga kelgan javob.
///
/// So'rov qismi yozuv yaratilganda ma'lum, javob qismini esa faqat [HttpLog]
/// to'ldiradi.
final class HttpLogEntry {
  HttpLogEntry._({
    required this.method,
    required this.url,
    required this.requestHeaders,
    required this.requestBody,
    required this.sentAt,
  });

  final String method;
  final Uri url;
  final Map<String, Object?> requestHeaders;
  final Object? requestBody;
  final DateTime sentAt;

  int? _statusCode;
  Object? _responseBody;
  String? _error;
  Duration? _duration;

  int? get statusCode => _statusCode;
  Object? get responseBody => _responseBody;
  String? get error => _error;
  Duration? get duration => _duration;

  // Holat status yoki xato matnidan emas, davomiylikdan aniqlanadi: Dio
  // xabarsiz `DioException` ham otadi, va ishonch_setapp'dagi nusxada bunday
  // yozuv abadiy «yuborilmoqda» bo'lib qolardi.
  bool get isPending => _duration == null;

  bool get hasError => _error != null || (_statusCode ?? 0) >= 400;
}

/// Staging'dagi HTTP so'rovlar jurnali. Jurnal ekrani unga obuna bo'ladi.
final class HttpLog extends ChangeNotifier {
  HttpLog({required DateTime Function() now}) : _now = now;

  // Javob tanalari xotirada turadi (KATM javobi ~1.7 MB) — jurnal cheksiz o'smasin.
  static const int capacity = 200;

  final DateTime Function() _now;
  final List<HttpLogEntry> _entries = <HttpLogEntry>[];

  /// Eng yangisi birinchi.
  List<HttpLogEntry> get entries => List<HttpLogEntry>.unmodifiable(_entries);

  HttpLogEntry start({required String method, required Uri url, required Map<String, Object?> headers, Object? body}) {
    final HttpLogEntry entry = HttpLogEntry._(
      method: method,
      url: url,
      requestHeaders: headers,
      requestBody: body,
      sentAt: _now(),
    );

    _entries.insert(0, entry);
    if (_entries.length > capacity) _entries.removeLast();

    notifyListeners();
    return entry;
  }

  void complete(HttpLogEntry entry, {int? statusCode, Object? responseBody, String? error}) {
    entry
      .._statusCode = statusCode
      .._responseBody = responseBody
      .._error = error
      .._duration = _now().difference(entry.sentAt);

    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}

/// So'rovlarni [HttpLog] ga yozadi. So'rovni ham, javobni ham o'zgartirmaydi.
final class HttpLogInterceptor extends Interceptor {
  const HttpLogInterceptor(this._log);

  final HttpLog _log;

  // Yozuv `hashCode` bo'yicha xaritada emas, so'rovning `extra` sida yuradi:
  // `RequestOptions.copyWith` qilingan so'rovning `hashCode` i boshqa bo'ladi
  // va yozuv topilmay «yuborilmoqda» da qotardi, `extra` esa nusxaga ko'chadi.
  static const String _entryKey = 'http_log_entry';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_entryKey] = _log.start(
      method: options.method,
      url: options.uri,
      headers: options.headers,
      body: options.data,
    );

    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.extra[_entryKey] case final HttpLogEntry entry) {
      _log.complete(entry, statusCode: response.statusCode, responseBody: response.data);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.requestOptions.extra[_entryKey] case final HttpLogEntry entry) {
      _log.complete(
        entry,
        statusCode: err.response?.statusCode,
        responseBody: err.response?.data,
        error: '${err.type.name}: ${err.message ?? err.error ?? '-'}',
      );
    }

    handler.next(err);
  }
}
