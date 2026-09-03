import 'package:colloborator_v3/features/contracts/domain/entities/credit_report.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_row.dart';
import 'package:equatable/equatable.dart';

/// Maketdagi bitta bo'lim: kaliti va sarlavhasi.
///
/// Javobda `type` ham keladi, lekin uning qiymatlari hujjatlashtirilmagan va
/// hech qayerda ishlatilmaydi — o'qilmaydi.
final class KatmSection extends Equatable {
  const KatmSection({required this.key, required this.title});

  final String key;
  final String title;

  @override
  List<Object?> get props => [key, title];
}

/// Bo'limning ma'lumoti: qatorlar va ixtiyoriy "Jami" qatori.
final class KatmTable extends Equatable {
  const KatmTable({required this.key, required this.rows, required this.totals});

  final String key;
  final List<KatmRow> rows;

  /// Faqat `open_contracts` da bo'ladi.
  final KatmRow? totals;

  @override
  List<Object?> get props => [key, rows, totals];
}

/// Gauge shkalasining bitta zonasi.
final class KatmBand extends Equatable {
  const KatmBand({required this.name, required this.from, required this.to});

  final String name;
  final int from;
  final int to;

  @override
  List<Object?> get props => [name, from, to];
}

/// Ball va uning shkalasi. Diapazon backenddan keladi, qat'iy yozilmaydi.
final class KatmScoring extends Equatable {
  const KatmScoring({
    required this.grade,
    required this.className,
    required this.level,
    required this.min,
    required this.max,
    required this.bands,
  });

  final int grade;
  final String className;
  final String level;
  final int min;
  final int max;
  final List<KatmBand> bands;

  /// Shkala kelganmi. Kelmasa gauge chizilmaydi — noto'g'ri chizilgan shkala
  /// ballni jimgina boshqa zonaga tushirib qo'yadi.
  bool get hasScale => max > min;

  /// Ballning shkaladagi o'rni, 0..1.
  double get position => hasScale ? ((grade - min) / (max - min)).clamp(0.0, 1.0) : 0;

  @override
  List<Object?> get props => [grade, className, level, min, max, bands];
}

/// Ball dinamikasining bitta nuqtasi. `period` — `MM.YYYY`.
final class KatmDynamic extends Equatable {
  const KatmDynamic({required this.period, required this.score});

  final String period;
  final int score;

  @override
  List<Object?> get props => [period, score];
}

final class KatmComment extends Equatable {
  const KatmComment({required this.order, required this.content});

  final int order;
  final String content;

  @override
  List<Object?> get props => [order, content];
}

/// Hujjat rekvizitlari.
final class KatmMeta extends Equatable {
  const KatmMeta({
    required this.reportName,
    required this.claimId,
    required this.claimDate,
    required this.orgName,
    required this.subjectType,
  });

  final String reportName;
  final String claimId;
  final String claimDate;
  final String orgName;
  final String subjectType;

  @override
  List<Object?> get props => [reportName, claimId, claimDate, orgName, subjectType];
}

/// KATM kredit byurosi hisoboti.
final class KatmReport extends Equatable {
  const KatmReport({
    required this.state,
    required this.title,
    required this.meta,
    required this.subject,
    required this.scoring,
    required this.dynamics,
    required this.overview,
    required this.hasCreditBan,
    required this.isBlacklisted,
    required this.layout,
    required this.tables,
    required this.comments,
    required this.scoredAt,
  });

  final ReportState state;
  final String title;
  final KatmMeta meta;

  /// 1-bo'lim: kredit axboroti subyekti.
  final KatmRow subject;

  final KatmScoring scoring;
  final List<KatmDynamic> dynamics;

  /// Umumiy ko'rsatkichlar bo'limi.
  final KatmRow overview;

  final bool hasCreditBan;
  final bool isBlacklisted;

  /// Bo'limlar tartibi backenddan keladi.
  final List<KatmSection> layout;

  final List<KatmTable> tables;
  final List<KatmComment> comments;
  final String scoredAt;

  bool get isAvailable => state == ReportState.available;

  bool get hasWarning => hasCreditBan || isBlacklisted;

  KatmTable? tableOf(String key) {
    for (final KatmTable table in tables) {
      if (table.key == key) return table;
    }

    return null;
  }

  @override
  List<Object?> get props => [
    state,
    title,
    meta,
    subject,
    scoring,
    dynamics,
    overview,
    hasCreditBan,
    isBlacklisted,
    layout,
    tables,
    comments,
    scoredAt,
  ];
}

/// KATM so'rovi ikkita raqamga bog'liq (3.3).
final class KatmParams extends Equatable {
  const KatmParams({required this.contractId, required this.clientId});

  final int contractId;
  final int clientId;

  @override
  List<Object?> get props => [contractId, clientId];
}
