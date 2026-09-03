import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_scoring.dart';

final class StopReasonDto {
  const StopReasonDto({required this.statusCode, required this.code, required this.description});

  factory StopReasonDto.fromJson(Map<String, dynamic> json) => StopReasonDto(
    statusCode: json['status_code'] as String? ?? '',
    code: json['code'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );

  final String statusCode;
  final String code;
  final String description;

  StopReason toEntity() => StopReason(statusCode: statusCode, code: code, description: description);
}

final class ExternalCheckDto {
  const ExternalCheckDto({
    required this.code,
    required this.nameUz,
    required this.nameRu,
    required this.descriptionUz,
    required this.descriptionRu,
    required this.reasons,
  });

  factory ExternalCheckDto.fromJson(Map<String, dynamic> json) => ExternalCheckDto(
    code: json['code'] as String? ?? '',
    nameUz: json['name_uz'] as String? ?? '',
    nameRu: json['name_ru'] as String? ?? '',
    descriptionUz: json['description_uz'] as String? ?? '',
    descriptionRu: json['description_ru'] as String? ?? '',
    reasons: JsonParser.list(json['reasons'], fromJson: StopReasonDto.fromJson),
  );

  final String code;
  final String nameUz;
  final String nameRu;
  final String descriptionUz;
  final String descriptionRu;
  final List<StopReasonDto> reasons;

  ExternalCheck toEntity(ExternalSource source) => ExternalCheck(
    source: source,
    code: code,
    nameUz: nameUz,
    nameRu: nameRu,
    descriptionUz: descriptionUz,
    descriptionRu: descriptionRu,
    reasons: reasons.map((StopReasonDto dto) => dto.toEntity()).toList(),
  );
}

final class ContractScoringDto {
  const ContractScoringDto({
    required this.clientId,
    required this.clientName,
    required this.statusCode,
    required this.limit,
    required this.freeLimit,
    required this.exceededLimit,
    required this.coBorrowerLimit,
    required this.asokiMonthlyPayment,
    required this.internal,
    required this.external,
  });

  factory ContractScoringDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> internal =
        json['internalStopFactors'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final Map<String, dynamic> external =
        json['externalStopFactors'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    ExternalCheckDto source(String key) =>
        ExternalCheckDto.fromJson(external[key] as Map<String, dynamic>? ?? const <String, dynamic>{});

    return ContractScoringDto(
      clientId: json['client_id'] as int? ?? 0,
      clientName: json['client_fio'] as String? ?? '',
      statusCode: json['status_code'] as String? ?? '',
      limit: json['limit'] as int? ?? 0,
      freeLimit: json['free_limit'] as int? ?? 0,
      exceededLimit: json['exceeded_limit'] as int? ?? 0,
      coBorrowerLimit: json['co_borrower_limit'] as int? ?? 0,
      asokiMonthlyPayment: json['asoki_monthly_payment'] as int? ?? 0,
      internal: <InternalCheckKind, String>{
        InternalCheckKind.age: internal['age'] as String? ?? '',
        InternalCheckKind.blacklist: internal['blacklist'] as String? ?? '',
        InternalCheckKind.criminalRecord: internal['criminal_record'] as String? ?? '',
        InternalCheckKind.clientScore: internal['client_score'] as String? ?? '',
      },
      external: <ExternalSource, ExternalCheckDto>{
        ExternalSource.mib: source('mib'),
        ExternalSource.misoki: source('misoki'),
        ExternalSource.kiats: source('kiats'),
        ExternalSource.asoki: source('asoki'),
        ExternalSource.gnkSalary: source('gnk_salary'),
        ExternalSource.pension: source('pension'),
        ExternalSource.cardTurnover: source('card_turnover'),
        ExternalSource.nibbd: source('nibbd'),
      },
    );
  }

  final int clientId;
  final String clientName;
  final String statusCode;
  final int limit;
  final int freeLimit;
  final int exceededLimit;
  final int coBorrowerLimit;
  final int asokiMonthlyPayment;
  final Map<InternalCheckKind, String> internal;
  final Map<ExternalSource, ExternalCheckDto> external;

  ContractScoring toEntity() => ContractScoring(
    clientId: clientId,
    clientName: clientName,
    statusCode: statusCode,
    limits: ScoringLimits(
      total: limit,
      free: freeLimit,
      exceeded: exceededLimit,
      coBorrower: coBorrowerLimit,
      asokiMonthlyPayment: asokiMonthlyPayment,
    ),
    internal: internal.entries
        .map((MapEntry<InternalCheckKind, String> e) => InternalCheck(kind: e.key, detail: e.value))
        .toList(),
    external: external.entries
        .map((MapEntry<ExternalSource, ExternalCheckDto> e) => e.value.toEntity(e.key))
        .toList(),
  );
}

/// Flex shartnomalarida ro'yxat tepasida ko'rsatiladigan xabar.
final class FlexMessageDto {
  const FlexMessageDto({required this.message});

  factory FlexMessageDto.fromJson(Map<String, dynamic> json) =>
      FlexMessageDto(message: json['message']?.toString() ?? '');

  final String message;
}
