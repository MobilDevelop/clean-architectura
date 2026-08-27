import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/contracts/data/models/guarantor_info_dto.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_status.dart';

final class ContractInfoDto {

 const ContractInfoDto({
    required this.id,
    required this.clientId,
    required this.clientFio, 
    required this.statusId, 
    required this.createdAt,
    required this.birthDay, 
    required this.passport,
    required this.isFormal,
    required this.isReturned,
    required this.isCard,
    required this.flex,
    required this.guarantors,
    required this.clientSignUrl,
    required this.isClientFace,
    required this.higherPositionConfirmationRequired,
    required this.isSentForApproval,
    required this.canUserAllowConfirmation,
    required this.sentUserFullname,
    required this.sentPartnerFullname,
    required this.sentAt,
    required this.scoringTime,
    required this.directorConfirmedAt,
    required this.showButtonKATM,
    required this.hasBenefit,
    required this.engine,
  }); 

  final int id;
  final int clientId;
  final String clientFio;
  final int statusId;
  final String createdAt;
  final String passport;
  final String birthDay;
  final String clientSignUrl;
  final String scoringTime;
  final String engine;
  final bool isFormal;
  final bool isReturned;
  final bool isCard;
  final bool flex;
  final bool isClientFace;
  final List<GuarantorInfoDto> guarantors;
  final bool higherPositionConfirmationRequired;
  final bool canUserAllowConfirmation;
  final bool isSentForApproval;
  final bool showButtonKATM;
  final bool hasBenefit;
  final String sentUserFullname;
  final String sentPartnerFullname;
  final String sentAt;
  final String directorConfirmedAt;

  ContractInfo toEntity()=>ContractInfo(
    id: id, 
    clientId: clientId, 
    clientFio: clientFio, 
    birthDay: birthDay, 
    passport: passport, 
    isFormal: isFormal, 
    isReturned: isReturned,
    createdAt: createdAt,
    isCard: isCard, 
    flex: flex,
    guarantors: guarantors.map((item) => item.toEntity()).toList(), 
    clientSignUrl: clientSignUrl, 
    isClientFace: isClientFace, 
    higherPositionConfirmationRequired: higherPositionConfirmationRequired, 
    isSentForApproval: isSentForApproval, 
    canUserAllowConfirmation: canUserAllowConfirmation, 
    sentUserFullname: sentUserFullname, 
    sentPartnerFullname: sentPartnerFullname, 
    showButtonKATM: showButtonKATM, 
    hasBenefit: hasBenefit, 
    engine: engine,
    status: _statusFrom(statusId),
    scoringTime: _dateFrom(scoringTime),
    sentAt: _dateFrom(sentAt),
    directorConfirmedAt: _dateFrom(directorConfirmedAt),
  );

  factory ContractInfoDto.fromJson(Map<String,dynamic> json)=>ContractInfoDto(
    id: json['id'] as int? ?? -1, 
    clientId: json['client_id'] as int? ?? -1,
    passport: json['passport_series_number'] as String? ?? "",
    birthDay: json['birth_date'] as String? ?? "",
    statusId: json['status_id'] as int? ?? -1, 
    clientFio: json['client_fio']as String? ?? "",
    isFormal: json['formal'] as bool? ?? false,
    isCard: json['has_client_plastic_card'] as bool? ?? false,
    flex: json['flex'] as bool? ?? false,
    createdAt: json['created_at']as String? ?? "",
    isClientFace: json['is_client_face_id_verified'] as bool? ?? false,
    clientSignUrl: json['client_sign_url'] as String? ?? "",
    isReturned: json['is_product_returned'] as bool? ?? false,
    engine: json['authority_engine'] as String? ?? '',
    guarantors: JsonParser.list(json['guarantors'], fromJson: GuarantorInfoDto.fromJson),
    higherPositionConfirmationRequired: json['higher_position_confirmation_required'] as bool? ?? false,
    isSentForApproval: json['is_sent_for_approval'] as bool? ?? false,
    canUserAllowConfirmation: json['can_user_allow_confirmation'] as bool? ?? false,
    sentUserFullname: json['sent_user_fullname'] as String? ?? "",
    sentPartnerFullname: json['sent_partner_fullname'] as String? ?? "",
    sentAt: json['sent_at'] as String? ?? "",
    scoringTime: json['updated_at'] as String? ?? "",
    hasBenefit: json['has_benefit'] as bool? ?? false,
    showButtonKATM: json['elma_katm_check_failed'] as bool? ?? false,
    directorConfirmedAt: json['director_confirmed_at'] as String? ?? "",
  );

  /// Backend kodini domain ma'nosiga o'giradi.
/// Nega bu yerda: kodlar backendniki, ular domainga o'tmasligi kerak.
ContractStatus _statusFrom(int code) => switch (code) {
  1 => ContractStatus.created,
  2 || 3 => ContractStatus.scoring,
  4 => ContractStatus.failed,
  5 || 23 => ContractStatus.notAllowed,
  6 => ContractStatus.rejected,
  7 => ContractStatus.edited,
  8 => ContractStatus.allowed,
  9 => ContractStatus.faceVerified,
  10 => ContractStatus.signed,
  11 => ContractStatus.confirmed,
  12 => ContractStatus.canceledByClient,
  15 => ContractStatus.invoiceCreated,
  16 => ContractStatus.canceled,
  24 => ContractStatus.waitingSms,
  25 => ContractStatus.errorFound,
  27 => ContractStatus.invoiceConfirmed,
  40 => ContractStatus.incomeSelect,
  _ => ContractStatus.unknown,
};

/// Bo'sh yoki noto'g'ri satr — "vaqt yo'q" degani.
DateTime? _dateFrom(String raw) => raw.isEmpty ? null : DateTime.tryParse(raw)?.toLocal();
}