import 'dart:io';

import 'package:colloborator_v3/core/error/error_mapper.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Har bir `DioException` turi qanday `Failure` ga aylanishini qulflaydi.
/// Bu funksiya tarmoq xatosida foydalanuvchi nima ko'rishini hal qiladi

void main() {
  final options = RequestOptions(path: '/test');

  DioException dioError(DioExceptionType type, {Object? error}) => DioException(requestOptions: options, type: type, error: error);

  DioException badResponse({required int statusCode, Object? data}) => DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(requestOptions: options, statusCode: statusCode, data: data),
      );

  group('Tarmoq va ulanish', () {
    test('ulanish vaqti tugasa — TimeoutFailure', () {
      final failure = ErrorMapper.fromDio(dioError(DioExceptionType.connectionTimeout));

      expect(failure, isA<TimeoutFailure>());
    });

    test('ulanish uzilsa — NetworkFailure', () {
      expect(ErrorMapper.fromDio(dioError(DioExceptionType.connectionError)), isA<NetworkFailure>());
    });

    /// `unknown` turi ichida SocketException yashiringan bo'lishi mumkin —
    /// bu ham internetning yo'qligi, foydalanuvchiga shunday aytilishi kerak
    test("unknown ichida SocketException bo'lsa — NetworkFailure", () {
      final failure = ErrorMapper.fromDio(dioError(DioExceptionType.unknown, error: const SocketException('failed')));

      expect(failure, isA<NetworkFailure>());
    });

    test("unknown ichida boshqa narsa bo'lsa — UnknownFailure", () {
      expect(ErrorMapper.fromDio(dioError(DioExceptionType.unknown)), isA<UnknownFailure>());
    });
  });

  group('Javob kodlari', () {
    test('401 — UnauthorizedFailure', () {
      expect(ErrorMapper.fromDio(badResponse(statusCode: 401)), isA<UnauthorizedFailure>());
    });

    test('500 — ServerFailure va statusCode saqlanadi', () {
      final failure = ErrorMapper.fromDio(badResponse(statusCode: 503));

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 503);
    });

    test('422 — ClientFailure', () {
      expect(ErrorMapper.fromDio(badResponse(statusCode: 422)), isA<ClientFailure>());
    });

    /// Server HTML xato sahifasini qaytarsa, statusCode 200 bo'lsa ham bu server xatosi
    test('HTML javob — ServerFailure', () {
      final failure = ErrorMapper.fromDio(badResponse(statusCode: 200, data: '<html><body>500</body></html>'));

      expect(failure, isA<ServerFailure>());
    });
  });

  group('Xabar matnini oqish', () {
    test('message kalitidan olinadi', () {
      final failure = ErrorMapper.fromDio(badResponse(statusCode: 422, data: {'message': 'Login band'}));

      expect(failure.message, 'Login band');
    });

    test('ichki data.message dan ham olinadi', () {
      final failure = ErrorMapper.fromDio(badResponse(statusCode: 422, data: {
        'data': {'message': 'Ichkaridagi xabar'}
      }));

      expect(failure.message, 'Ichkaridagi xabar');
    });

    test('xabar bolmasa — zaxira matn ishlatiladi', () {
      final failure = ErrorMapper.fromDio(badResponse(statusCode: 401));

      expect(failure.message, isNotEmpty);
    });
  });
}