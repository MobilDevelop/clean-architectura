import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';

/// Qidiruv xatosining foydalanuvchiga ko'rinadigan matni.
abstract final class CustomerSearchIssueText {
  static String? of(CustomerSearchIssue issue) => switch (issue) {
    CustomerSearchIssue.none => null,
    CustomerSearchIssue.shortName => "Kamida 3 ta harf kiriting",
    CustomerSearchIssue.invalidName => "Faqat harf, bo'sh joy va tire ishlatiladi",
    CustomerSearchIssue.incompleteInps => "INPS 14 xonadan iborat",
    CustomerSearchIssue.incompletePassport => "Pasport AA1234567 shaklida bo'ladi",
  };
}
