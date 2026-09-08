import 'package:colloborator_v3/core/session/app_user.dart';

/// Backend'ning `user` obyekti. Shakli backendniki — snake_case nomlar,
/// yo'q bo'lishi mumkin bo'lgan maydonlar. Ilova bu shaklga bog'lanmasligi uchun
/// `toEntity()` chegara vazifasini bajaradi.
final class UserDto {
  const UserDto({
    required this.id,
    required this.fio,
    required this.username,
    required this.phone,
    required this.rule,
    required this.organization,
    required this.organizationId,
    required this.mustUpdatePassword,
    required this.permissionsDto,
    required this.companyDto,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as int,
        fio: json['fio'] as String,
        username: json['username'] as String,
        phone: json['phone_number'] as String,
        rule: json['rule'] as String,
        organization: json['name'] as String,
        organizationId: json['organization_id'] as int,
        mustUpdatePassword: json['password_update_note'] as bool,
        companyDto: json['company_id'] == null ? null : CompanyDto.fromJson(json),
        permissionsDto: PermissionsDto.fromUserJson(json),
      );

  final int id;
  final String fio;
  final String username;
  final String phone;
  final String rule;
  final String organization;
  final int organizationId;
  final bool mustUpdatePassword;
  final CompanyDto? companyDto;
  final PermissionsDto permissionsDto;

  User toEntity() => User(
    id: id,
    fio: fio,
    username: username,
    phone: phone,
    rule: rule,
    organization: organization,
    organizationId: organizationId,
    mustUpdatePassword: mustUpdatePassword,
    company: companyDto?.toEntity(),
    permissions: permissionsDto.toEntity(),
  );
}

/// Ruxsatlar faqat ichma-ich `permissions` obyektida keladi.
/// Guruh yo'q bo'lsa yoki qiymat mantiqiy tip bo'lmasa — ruxsat yo'q.
final class PermissionsDto {
  const PermissionsDto({
    required this.showScoringResult,
    required this.showPrescoring,
    required this.showScoringCard,
    required this.showKatmButton,
  });

  factory PermissionsDto.fromUserJson(Map<String, dynamic> json) {
    final raw = json['permissions'];
    final groups = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};

    return PermissionsDto(
      showKatmButton: _flag(groups['scoring'], 'turn-off-katm'),
      showScoringResult: _flag(groups['local_scoring_result'], 'show'),
      showPrescoring: _flag(groups['prescoring'], 'show'),
      showScoringCard: _flag(groups['prescoring'], 'card'),
    );
  }

  /// Guruh yo'q yoki qiymat mantiqiy tip emas — ruxsat berilmagan.
  static bool _flag(Object? group, String key) => group is Map && group[key] is bool && group[key] as bool;

  final bool showScoringResult;
  final bool showPrescoring;
  final bool showScoringCard;
  final bool showKatmButton;

  UserPermissions toEntity() => UserPermissions(
    showScoringResult: showScoringResult,
    showPrescoring: showPrescoring,
    showScoringCard: showScoringCard,
    showKatmButton: showKatmButton,
  );
}

final class CompanyDto{
  CompanyDto({required this.id,required this.title});
  
  final int id;
  final String title;

  Company toEntity()=>Company(id: id, title: title);

  factory CompanyDto.fromJson(Map<String,dynamic> json)=>CompanyDto(
    id: json['company_id'] as int, 
    title: json['company'] as String
  );
}