import 'dart:io';

import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_data.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';

abstract interface class UnderwriterRepository {
  /// Beshala bo'limning saqlangan holati.
  Future<Result<UnderwriterData>> load(int contractId);

  Future<Result<List<MilitaryPosition>>> getPositions();

  Future<Result<List<UnderwriterOption>>> getCarBrands();

  Future<Result<List<UnderwriterOption>>> getCarModels(int brandId);

  /// Faylni S3 ga yuklaydi va kalitini qaytaradi.
  ///
  /// Ikki qadam bitta amal sifatida: avval imzolangan havola olinadi, keyin
  /// baytlar o'sha havolaga yuboriladi. Ikkinchisi yiqilsa kalit qaytmaydi —
  /// flex esa yuklanmagan faylning kalitini ham yozib qo'yardi.
  Future<Result<String>> uploadFile(File file);

  /// Bo'limni saqlaydi. `editId` noldan farqli bo'lsa `PUT`.
  Future<Result<void>> save(SaveUnderwriterParams params);
}
