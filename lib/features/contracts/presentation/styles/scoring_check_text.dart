import 'package:colloborator_v3/features/contracts/domain/entities/contract_scoring.dart';

/// Tekshiruvlarning ekrandagi nomlari.
abstract final class ScoringCheckText {
  static String internal(InternalCheckKind kind) => switch (kind) {
    InternalCheckKind.age => "Yosh tekshiruvi",
    InternalCheckKind.blacklist => "Qora ro'yxat",
    InternalCheckKind.criminalRecord => "Sud holati",
    InternalCheckKind.clientScore => "To'lov intizomi",
  };

  static String external(ExternalSource source) => switch (source) {
    ExternalSource.mib => "MIB",
    ExternalSource.misoki => "Misoki",
    ExternalSource.kiats => "KIATS",
    ExternalSource.asoki => "Asoki",
    ExternalSource.gnkSalary => "Soliq qo'mitasi (ish haqi)",
    ExternalSource.pension => "Pensiya jamg'armasi",
    ExternalSource.cardTurnover => "Karta aylanmasi",
    ExternalSource.nibbd => "NIBBD",
  };
}
