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
/// buzadi. Asosiy klientning interceptorlari esa ikkalasini ham har so'rovga
/// qo'shadi. Shuning uchun bu klientda na `baseUrl`, na so'rovni o'zgartiradigan
/// interceptor bor.
///
/// So'rovga hech nima qo'shmaydigan interceptorlar esa **beriladi**. Xato
/// haqida xabar beruvchisiz fayl yuklashdagi har qanday nosozlik botga umuman
/// yetib bormasdi — `guard` esa har qanday `DioException` ni «interceptor ko'rdi»
/// deb hisoblab, uni ikkinchi marta yubormasdi (5.7). Staging'dagi HTTP jurnal
/// ham shu turdagi interceptor.
///
/// Bu 12-bo'limdagi "global Dio nusxasi" taqiqiga zid emas: nusxa servis
/// ichida emas, DI da yaratiladi va tipi bilan nima uchun kerakligini aytadi.
final class UploadClient {
  const UploadClient(this.dio);

  final Dio dio;
}

UploadClient createUploadClient({required List<Interceptor> interceptors}) {
  final Dio dio = Dio(
    BaseOptions(
      // Fayl yuklash sekin tarmoqda uzoq davom etadi.
      sendTimeout: const Duration(minutes: 3),
      receiveTimeout: const Duration(minutes: 1),
    ),
  );

  dio.interceptors.addAll(interceptors);

  return UploadClient(dio);
}
