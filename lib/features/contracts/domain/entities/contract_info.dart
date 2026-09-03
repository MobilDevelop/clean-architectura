import 'package:colloborator_v3/features/contracts/domain/entities/contract_status.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/guarantor_info.dart';
import 'package:equatable/equatable.dart';

final class ContractInfo extends Equatable {
  const ContractInfo({
    required this.id,
    required this.clientId,
    required this.clientFio,
    required this.status,
    required this.birthDay,
    required this.passport,
    required this.isFormal,
    required this.isReturned,
    required this.isCard,
    required this.flex,
    required this.createdAt,
    required this.guarantors,
    required this.clientSignUrl,
    required this.isClientFace,
    required this.higherPositionConfirmationRequired,
    required this.isSentForApproval,
    required this.canUserAllowConfirmation,
    required this.sentUserFullname,
    required this.sentPartnerFullname,
    required this.showButtonKATM,
    required this.hasBenefit,
    required this.engine,
    this.directorConfirmedAt,
    this.scoringTime,
    this.sentAt,
  });

  final int id;
  final int clientId;

  final String clientFio;
  final String passport;
  final String birthDay;
  final String clientSignUrl;
  final String engine;
  final String createdAt;
  final String sentUserFullname;
  final String sentPartnerFullname;

  final bool isFormal;
  final bool isReturned;
  final bool isCard;
  final bool flex;
  final bool isClientFace;
  final bool higherPositionConfirmationRequired;
  final bool canUserAllowConfirmation;
  final bool isSentForApproval;
  final bool showButtonKATM;
  final bool hasBenefit;

  final List<GuarantorInfo> guarantors;
  final ContractStatus status;
  final DateTime? directorConfirmedAt;
  final DateTime? scoringTime;
  final DateTime? sentAt;

  bool get needsApproval =>
      status == ContractStatus.allowed && (higherPositionConfirmationRequired || canUserAllowConfirmation);

  @override
  List<Object?> get props => [
    id,
    clientId,
    clientFio,
    createdAt,
    birthDay,
    passport,
    isFormal,
    isReturned,
    isCard,
    flex,
    guarantors,
    clientSignUrl,
    isClientFace,
    higherPositionConfirmationRequired,
    isSentForApproval,
    status,
    canUserAllowConfirmation,
    sentPartnerFullname,
    sentUserFullname,
    showButtonKATM,
    hasBenefit,
    engine,
    directorConfirmedAt,
    scoringTime,
    sentAt,
  ];
}
