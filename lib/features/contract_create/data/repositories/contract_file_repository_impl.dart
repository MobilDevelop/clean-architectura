import 'dart:io';

import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/contract_file_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_file_repository.dart';

final class ContractFileRepositoryImpl implements ContractFileRepository {
  const ContractFileRepositoryImpl({required this._remote});

  final ContractFileRemoteDatasource _remote;

  @override
  Future<Result<File>> download(String url) => guard(() async {
    if (url.trim().isEmpty) throw const FormatException('shartnoma fayli havolasi bo‘sh');

    final File file = await _remote.download(url);

    // Bo'sh fayl ham xato: ulashish oynasi ochilar, lekin qabul qiluvchiga
    // ochilmaydigan hujjat ketardi (5.8).
    if (await file.length() == 0) throw const FormatException('shartnoma fayli bo‘sh');

    return file;
  });
}
