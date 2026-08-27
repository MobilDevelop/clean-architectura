import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/auth/registration/domain/entities/registration_param.dart';
import 'package:colloborator_v3/features/auth/registration/domain/entities/partner.dart';

abstract interface class RegistrationRepository {
  Future<Result<List<Partner>>> getPartners(String search);

  /// Ariza yuboriladi. Qaytadigan `String` — serverdan kelgan xabar matni,
  /// foydalanuvchiga o'zgarishsiz ko'rsatiladi. Ilova uni tahlil qilmaydi
  Future<Result<String>> registration(RegistrationParam param);
}