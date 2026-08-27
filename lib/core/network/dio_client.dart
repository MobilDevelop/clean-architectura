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
      sendTimeout: const Duration(seconds: 30),
      headers: const {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
      },
    ),
  );

  dio.interceptors.addAll(interceptors);

  return dio;
}