import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/card_confirmation.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/card_confirm_repository.dart';

final class GetCardConfirmationUsecase implements UseCase<CardConfirmation, int> {
  const GetCardConfirmationUsecase(this._repository);

  final CardConfirmRepository _repository;

  @override
  Future<Result<CardConfirmation>> call(int params) => _repository.get(params);
}

/// Tasdiqlashni yuboradi.
///
/// Amalga qarab nima to'ldirilishi shart bo'lgani shu yerda tekshiriladi
/// (3.8): kod amalida kod, karta amalida karta maydonlari. Ekran tugmani
/// o'chirib qo'yadi, lekin qoida ekranda emas — ikkinchi kirish yo'li paydo
/// bo'lsa u ham shu tekshiruvdan o'tadi.
final class SubmitCardConfirmationUsecase implements UseCase<void, CardConfirmParams> {
  const SubmitCardConfirmationUsecase(this._repository);

  final CardConfirmRepository _repository;

  @override
  Future<Result<void>> call(CardConfirmParams params) async {
    // Karta boshqa shaxsniki — server har qanday davom etishni rad etadi.
    if (params.confirmation.isOwnerMismatch) {
      return const Err<void>(ClientFailure('Karta boshqa shaxsga tegishli'));
    }

    switch (params.action) {
      case CardConfirmAction.code:
        if (params.code.trim().isEmpty) return const Err<void>(ClientFailure('SMS kodni kiriting'));
      case CardConfirmAction.saveCard:
        final CardConfirmIssue issue = params.entry.issue;
        if (issue != CardConfirmIssue.none) return Err<void>(ClientFailure(_reason(issue)));
      case CardConfirmAction.resend:
      case CardConfirmAction.skipCard:
        break;
    }

    return _repository.submit(params);
  }

  static String _reason(CardConfirmIssue issue) => switch (issue) {
    CardConfirmIssue.none => '',
    CardConfirmIssue.codeMissing => 'SMS kodni kiriting',
    CardConfirmIssue.cardNumberShort => 'Karta raqami 16 xonadan iborat',
    CardConfirmIssue.expiryInvalid => 'Karta muddati yaroqsiz',
    CardConfirmIssue.phoneShort => 'Telefon raqami toʻliq emas',
  };
}
