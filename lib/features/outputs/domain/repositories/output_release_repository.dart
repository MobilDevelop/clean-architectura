import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_release.dart';

/// Chiqim shartnomasi ustidagi amallar: tovar berish va tovar qaytarish.
///
/// Ro'yxatdan alohida shartnoma (10-bo'lim, I): ro'yxatni ochadigan ekran bu
/// amallarni bilishi shart emas, va amallar endpointi o'zgarganda ro'yxat
/// shartnomasi o'zgarmaydi.
abstract interface class OutputReleaseRepository {
  /// Tovarlar surati va SMS kod bilan chiqimni tasdiqlaydi.
  Future<Result<void>> confirmRelease(ReleaseParams params);

  /// Tanlangan tovarlarni qaytaradi.
  Future<Result<void>> returnProducts(ProductReturnParams params);
}
