import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/data/datasources/card_confirm_remote_datasource.dart';
import 'package:colloborator_v3/features/contracts/data/models/card_confirmation_dto.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/card_confirmation.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/card_confirm_repository.dart';

final class CardConfirmRepositoryImpl implements CardConfirmRepository {
  const CardConfirmRepositoryImpl({required this._remote});

  final CardConfirmRemoteDatasource _remote;

  @override
  Future<Result<CardConfirmation>> get(int contractId) => guard(() async {
    final CardConfirmationDto? dto = await _remote.get(contractId);

    // Bo'sh javob — ELMA holati noma'lum. Flex bunday holatda bo'sh modelni
    // qaytarardi va ekran raqamsiz, hisoblagichsiz OTP oynasini chizardi:
    // xodim kod kutib turardi, kod esa umuman yuborilmagan (5.8).
    if (dto == null) throw const FormatException('sms_for_card_confirmation bo‘sh');

    return dto.toEntity();
  });

  @override
  Future<Result<void>> submit(CardConfirmParams params) => guard(() => _remote.submit(params));
}
