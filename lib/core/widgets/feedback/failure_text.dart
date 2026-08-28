import 'package:colloborator_v3/core/error/failure.dart';

/// Xatoning foydalanuvchiga ko'rsatiladigan matni.
///
/// Nega alohida: `internal` guruhdagi xatoni foydalanuvchi tuzata olmaydi va
/// unga texnik matn ("Server javobi kutilgan shaklda emas") hech nima bermaydi.
/// Bu qoida bitta joyda tursin — aks holda har ekran o'zicha hal qiladi.
abstract final class FailureText {
  static const String _internal = "Xatolik yuz berdi. Birozdan keyin qayta urinib ko'ring";

  static String of(Failure failure) => switch (failure.group) {
    FailureGroup.internal => _internal,
    FailureGroup.session || FailureGroup.connection || FailureGroup.input => failure.message,
  };
}
