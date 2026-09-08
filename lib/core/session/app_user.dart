import 'package:equatable/equatable.dart';

// Tizimga kirgan hodim. Backend yuborgan hamma narsa emas —
// faqat ilova haqiqatan ishlatadigan maydonlar.
final class User extends Equatable {
  const User({
    required this.id,
    required this.fio,
    required this.username,
    required this.phone,
    required this.rule,
    required this.organization,
    required this.organizationId,
    required this.mustUpdatePassword,
    required this.permissions,
    this.company,
  });

  final int id;
  final String fio;
  final String username;
  final String phone;
  final String rule;
  final String organization;
  final int organizationId;
  final bool mustUpdatePassword;
  final Company? company;
  final UserPermissions permissions;

  @override
  List<Object?> get props => [id, fio, username, phone, rule, company, organization, organizationId, mustUpdatePassword, permissions];
}

// Hodimga ochilgan imkoniyatlar. Backend'da alohida `permissions` obyektida keladi
// va birga o'zgaradi, shuning uchun `User` ga sochib tashlanmagan.
final class UserPermissions extends Equatable {
  const UserPermissions({
     this.showScoringResult,
     this.showPrescoring,
     this.showScoringCard,
     this.showKatmButton,
  });

  const UserPermissions.none()
      : showScoringResult = false,
        showPrescoring = false,
        showScoringCard = false,
        showKatmButton = false;

  final bool? showScoringResult;
  final bool? showPrescoring;
  final bool? showScoringCard;
  final bool? showKatmButton;

  @override
  List<Object?> get props => [showScoringResult, showPrescoring, showScoringCard, showKatmButton];
}

final class Company extends Equatable{

  const Company({required this.id,required this.title});

  final int id;
  final String title;

  @override
  List<Object?> get props => [id,title];
}