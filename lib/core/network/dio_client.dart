import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Ilovadagi yagona Dio nusxasi. Interceptorlar tashqaridan beriladi —
/// shuning uchun testda soxta interceptor bilan almashtirish mumkin.
Dio createDio({required List<Interceptor> interceptors}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['mainURL'] ?? '',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(minutes: 3),
      headers: const {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
      },
    ),
  );

  dio.interceptors.addAll(interceptors);

  return dio;
}

/// Tashqi xizmatga (imzolangan S3 havolasiga) fayl yuborish uchun klient.
///
/// Nega alohida nusxa: imzolangan havolaga bizning `Authorization` headerimiz
/// ham, `Content-Type: application/json` ham ketmasligi kerak — ular imzoni
/// buzadi. Interceptorlar esa ikkalasini ham har so'rovga qo'shadi. Shuning
/// uchun bu klientda na interceptor, na `baseUrl` bor.
///
/// Bu 12-bo'limdagi "global Dio nusxasi" taqiqiga zid emas: nusxa servis
/// ichida emas, DI da yaratiladi va tipi bilan nima uchun kerakligini aytadi.
final class UploadClient {
  const UploadClient(this.dio);

  final Dio dio;
}

UploadClient createUploadClient() => UploadClient(
  Dio(
    BaseOptions(
      // Fayl yuklash sekin tarmoqda uzoq davom etadi.
      sendTimeout: const Duration(minutes: 3),
      receiveTimeout: const Duration(minutes: 1),
    ),
  ),
);
