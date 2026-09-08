import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/katm_skip.dart';

abstract interface class KatmSkipRepository {
  Future<Result<List<SkipReason>>> getReasons();

  /// KATM/MIB tekshiruvini o'chiradi.
  ///
  /// Server HTTP 200 bilan `success: false` qaytarishi mumkin — bu ham xato
  /// va repositoryda `Err` ga aylantiriladi.
  Future<Result<void>> turnOffKatm(KatmSkipParams params);
}
