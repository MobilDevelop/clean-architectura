import 'package:colloborator_v3/features/contracts/domain/entities/contract_authority.dart';

final class ContractAuthorityDto {
  const ContractAuthorityDto({
    required this.message,
    required this.canProceed,
    required this.canApprove,
    required this.canEscalate,
    required this.canCancel,
  });

  factory ContractAuthorityDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> permissions =
        json['permissions'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    return ContractAuthorityDto(
      message: json['message'] as String? ?? '',
      // `can_proceed` ildizdan ham o'qiladi — backend joyini o'zgartirsa buzilmasin.
      canProceed: permissions['can_proceed'] as bool? ?? json['can_proceed'] as bool? ?? false,
      canApprove: permissions['can_approve'] as bool? ?? false,
      canEscalate: permissions['can_escalate'] as bool? ?? false,
      canCancel: permissions['can_cancel'] as bool? ?? false,
    );
  }

  final String message;
  final bool canProceed;
  final bool canApprove;
  final bool canEscalate;
  final bool canCancel;

  ContractAuthority toEntity() => ContractAuthority(
    message: message,
    canProceed: canProceed,
    canApprove: canApprove,
    canEscalate: canEscalate,
    canCancel: canCancel,
  );
}
