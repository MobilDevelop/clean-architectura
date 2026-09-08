import 'package:colloborator_v3/core/error/error_mapper.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:dio/dio.dart';

/// Istisnoni `Failure` ga o'giradigan yagona joy.
///
/// Nega funksiya: 5.5 har bir repository metodida oxirgi `catch (_)` ni talab
/// qiladi. Uni har bir metodda qo'lda yozish — bu qoidani unutish mumkin
/// degani. Barcha metod shu qopqoq orqali o'tsa, unutib bo'lmaydi.
Future<Result<T>> guard<T>(Future<T> Function() run) async {
  try {
    return Ok<T>(await run());
  } on DioException catch (e) {
    return Err<T>(ErrorMapper.fromDio(e));
  } on TypeError catch (_) {
    return Err<T>(const ParseFailure('Server javobi kutilgan shaklda emas'));
  } catch (_) {
    return Err<T>(const UnknownFailure('Kutilmagan xatolik yuz berdi'));
  }
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
