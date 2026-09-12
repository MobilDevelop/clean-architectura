import 'package:colloborator_v3/features/contracts/domain/entities/contract_signing.dart';

/// `sign_client_contract` / `sign_guarantor_contract` javobi.
final class SignatureResultDto {
  const SignatureResultDto(this._json, {required this.statusCode});

  factory SignatureResultDto.fromJson(Map<String, dynamic> json, {required int statusCode}) =>
      SignatureResultDto(json, statusCode: statusCode);

  final Map<String, dynamic> _json;

  /// 201 — server shartnoma to'liq imzolandi dedi.
  final int statusCode;

  static const int _signedStatus = 201;

  SignatureResult toEntity() => SignatureResult(
    signUrl: _json['url']?.toString() ?? '',
    isContractSigned: statusCode == _signedStatus,
  );
}
