import 'dart:io';

import 'package:colloborator_v3/core/error/error_mapper.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:dio/dio.dart';

typedef GuardReporter = void Function(Failure failure, Object error, StackTrace trace);

/// `guard` ushlagan istisnolarni kuzatuvchi.
///
/// Nega kerak: `ErrorReportInterceptor` faqat interceptor zanjiridan o'tgan
/// `DioException` ni ko'radi. Zanjirdan tashqaridagi hamma narsa — DTO'dagi
/// `TypeError`, buzuq shakl, kutilmagan istisno — 5.7 aynan xabar berishni
/// talab qiladigan sinf bo'lsa ham, hech qayerga yetib bormasdi.
abstract final class GuardReport {
  /// `injection.dart` da botga ulanadi.
  static GuardReporter? reporter;
}

/// Istisnoni `Failure` ga o'giradigan yagona joy.
///
/// Nega funksiya: 5.5 har bir repository metodida oxirgi `catch (_)` ni talab
/// qiladi. Uni har bir metodda qo'lda yozish — bu qoidani unutish mumkin
/// degani. Barcha metod shu qopqoq orqali o'tsa, unutib bo'lmaydi.
///
/// Nega `core/` da: uni `contract_create` ham, `underwriter` ham ishlatadi (1.2).
Future<Result<T>> guard<T>(Future<T> Function() run) async {
  try {
    return Ok<T>(await run());
  } on DioException catch (e, s) {
    return _err<T>(ErrorMapper.fromDio(e), e, s);
  } on TypeError catch (e, s) {
    return _err<T>(const ParseFailure('Server javobi kutilgan shaklda emas'), e, s);
  } on FormatException catch (e, s) {
    // Tafsilot (qaysi maydon, qanday tip) foydalanuvchiga emas, botga ketadi.
    return _err<T>(const ParseFailure('Server javobi kutilgan shaklda emas'), e, s);
  } on FileSystemException catch (e, s) {
    return _err<T>(const UnknownFailure('Faylni o‘qib bo‘lmadi'), e, s);
  } catch (e, s) {
    return _err<T>(const UnknownFailure('Kutilmagan xatolik yuz berdi'), e, s);
  }
}

Result<T> _err<T>(Failure failure, Object error, StackTrace trace) {
  // `DioException` ni odatda `ErrorReportInterceptor` yuboradi — takrorlamaymiz.
  //
  // Istisno: javobni tipga keltirishda otilgan xato ham `DioException` bo'lib
  // keladi, lekin u interceptor zanjiri tugagandan **keyin** yaraladi
  // (`dio_mixin.dart:576` → `assureDioException`), ya'ni interceptorga umuman
  // yetib bormaydi. Uni shu yerdan yubormasak, hech kim ko'rmaydi.
  final bool seenByInterceptor = error is DioException && error.error is! TypeError;

  if (failure.isReportable && !seenByInterceptor) GuardReport.reporter?.call(failure, error, trace);

  return Err<T>(failure);
}

/// `null` javobni `ParseFailure` ga aylantiradi.
///
/// Server qator id sini bermasa, keyingi tahrirlash va o'chirish ishlamaydi —
/// buni jimgina o'tkazib yuborish mumkin emas (5.8).
Result<T> requireValue<T extends Object>(
  Result<T?> result, {
  String message = 'Server javobi kutilgan shaklda emas',
}) => switch (result) {
  Ok(: final T? value) => value == null ? Err<T>(ParseFailure(message)) : Ok<T>(value),
  Err(: final Failure failure) => Err<T>(failure),
};
