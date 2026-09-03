import 'package:colloborator_v3/features/customers/domain/entities/customer_form.dart';

/// Har bir xato o'z maydoni tagida chiqadi (7.5).
abstract final class CustomerFormIssueText {
  static String? province(CustomerFormIssue issue) =>
      issue == CustomerFormIssue.provinceMissing ? "Viloyatni tanlang" : null;

  static String? region(CustomerFormIssue issue) => issue == CustomerFormIssue.regionMissing ? "Tumanni tanlang" : null;

  static String? village(CustomerFormIssue issue) =>
      issue == CustomerFormIssue.villageMissing ? "Mahallani tanlang" : null;

  static String? street(CustomerFormIssue issue) =>
      issue == CustomerFormIssue.streetMissing ? "Ko'cha nomini yozing" : null;

  static String? house(CustomerFormIssue issue) => issue == CustomerFormIssue.houseMissing ? "Uy raqamini yozing" : null;

  static String? mainPhone(CustomerFormIssue issue) =>
      issue == CustomerFormIssue.mainPhoneInvalid ? "Raqamni to'liq kiriting" : null;

  static String? relativePhone(CustomerFormIssue issue) =>
      issue == CustomerFormIssue.relativePhoneInvalid ? "Raqamni to'liq kiriting" : null;

  static String? relativeKind(CustomerFormIssue issue) =>
      issue == CustomerFormIssue.relativeKindMissing ? "Kim ekanini tanlang" : null;

  static String? friendPhone(CustomerFormIssue issue) =>
      issue == CustomerFormIssue.friendPhoneInvalid ? "Raqamni to'liq kiriting" : null;

  static String? workplace(CustomerFormIssue issue) =>
      issue == CustomerFormIssue.workplaceMissing ? "Ish joyini tanlang" : null;
}
