import 'dart:io';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:dio/dio.dart';

// `DioException` ni ilovaning xato tiliga o'giradi.
// Bu yerda UI ko'rsatilmaydi va log yozilmaydi — faqat tarjima.
abstract final class ErrorMapper {
  static Failure fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutFailure("So'rov vaqti tugadi. Qayta urinib ko'ring");

      case DioExceptionType.connectionError: return const NetworkFailure('Internetga ulanish mavjud emas');
      case DioExceptionType.badCertificate: return const NetworkFailure("Xavfsiz ulanishni o'rnatib bo'lmadi");
      case DioExceptionType.cancel: return const UnknownFailure("So'rov bekor qilindi");
      case DioExceptionType.badResponse: return _fromResponse(e.response);

      case DioExceptionType.unknown:
        if (e.error is SocketException) return const NetworkFailure('Internetga ulanish mavjud emas');
        return const UnknownFailure('Kutilmagan xatolik yuz berdi');
    }
  }

  static Failure _fromResponse(Response<dynamic>? response) {
    final data = response?.data;

    // Server xato sahifasini qaytardi — bu 5xx bilan bir xil holat
    if (data is String && data.contains('<html')) return ServerFailure('Server xatoligi', statusCode: response?.statusCode);

    final status = response?.statusCode ?? 0;
    final message = _readMessage(data);

    if (status == 401) return UnauthorizedFailure(message ?? 'Sessiya muddati tugadi');
    if (status >= 500) return ServerFailure(message ?? 'Server xatoligi', statusCode: status);
    if (status >= 400) return ClientFailure(message ?? "So'rov bajarilmadi", statusCode: status);

    return UnknownFailure(message ?? 'Kutilmagan javob');
  }

  // Backend xato matnini turli kalitlarda yuboradi
  static String? _readMessage(dynamic data) {
    if (data is! Map) return null;

    final direct = data['message'] ?? data['error'];
    if (direct is String && direct.isNotEmpty) return direct;

    final nested = data['data'];
    if (nested is Map) {
      final inner = nested['message'] ?? nested['error'];
      if (inner is String && inner.isNotEmpty) return inner;
    }

    return null;
  }
}