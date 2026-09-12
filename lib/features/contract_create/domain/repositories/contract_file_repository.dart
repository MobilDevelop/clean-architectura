import 'dart:io';

import 'package:colloborator_v3/core/result/result.dart';

abstract interface class ContractFileRepository {
  /// Shartnoma faylini vaqtinchalik papkaga yuklab oladi.
  ///
  /// Ulashish oynasi haqiqiy faylni talab qiladi — havolaning o'zini yuborish
  /// qabul qiluvchini avtorizatsiya so'raydigan sahifaga olib borardi.
  Future<Result<File>> download(String url);
}
