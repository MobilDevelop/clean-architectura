import 'package:colloborator_v3/features/contracts/domain/entities/card_confirmation.dart';

int _int(Object? raw) => raw == null ? 0 : (num.tryParse(raw.toString()) ?? 0).toInt();

String _digits(Object? raw) => raw?.toString().replaceAll(RegExp(r'\D'), '') ?? '';

Map<String, dynamic> _object(Object? raw) =>
    raw is Map<String, dynamic> ? raw : const <String, dynamic>{};

/// `GET get_sms_for_card_confirmation/{id}` javobi.
final class CardConfirmationDto {
  const CardConfirmationDto(this._json);

  factory CardConfirmationDto.fromJson(Map<String, dynamic> json) => CardConfirmationDto(json);

  final Map<String, dynamic> _json;

  /// ELMA OTP yubormaydigan yagona holat. `state` tekshirilmaydi: ELMA buni
  /// `"2"` bilan ham, `"4"` bilan ham yuborishi mumkin (flex izohi).
  static const String _ownerMismatch = 'card_owner_mismatch';

  CardConfirmation toEntity() {
    final Map<String, dynamic> card = _object(_json['card']);

    return CardConfirmation(
      contractId: _int(_json['contract_id']),
      cardId: _int(_json['card_id']),
      elmaApplicationId: _json['elma_application_id']?.toString() ?? '',
      elmaInstanceId: _json['elma_instanceid']?.toString() ?? '',
      phone: _digits(_json['phone_number']),
      message: _json['text']?.toString() ?? '',
      step: CardConfirmStep.fromCode(_json['state']?.toString() ?? ''),
      // Sana buzuq kelsa `null` bo'ladi va ekran hisoblagichsiz chiziladi.
      // Flex `DateTime.parse` ni to'g'ridan-to'g'ri chaqirardi va istisno
      // otardi.
      expiresAt: DateTime.tryParse(_json['sms_code_expired_time']?.toString() ?? ''),
      cardNumber: _digits(card['card_number']),
      cardExpiry: card['validity_date']?.toString() ?? '',
      isOwnerMismatch: _json['error_code']?.toString() == _ownerMismatch,
    );
  }
}
