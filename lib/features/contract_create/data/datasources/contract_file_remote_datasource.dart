import 'dart:io';

import 'package:dio/dio.dart';

final class ContractFileRemoteDatasource {
  const ContractFileRemoteDatasource({required this._dio});

  /// Faylni to'g'ridan-to'g'ri havoladan oladi.
  ///
  /// Bu S3 havolasi va u imzolangan — bizning `Authorization` sarlavhamiz
  /// unga kerak emas. Shuning uchun interceptorli asosiy klient emas
  /// (`UploadClient` bilan bir xil sabab).
  final Dio _dio;

  Future<File> download(String url) async {
    final Directory folder = await Directory.systemTemp.createTemp('contract');
    final String path = '${folder.path}/${_nameOf(url)}';

    await _dio.download(url, path);

    return File(path);
  }

  /// Havoladan fayl nomini ajratadi: `.../shartnoma_55.pdf?sig=…` → `shartnoma_55.pdf`.
  String _nameOf(String url) {
    final String last = url.split('/').last.split('?').first;

    return last.isEmpty ? 'shartnoma.pdf' : last;
  }
}
