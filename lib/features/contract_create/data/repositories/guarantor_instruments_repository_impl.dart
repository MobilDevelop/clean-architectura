import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/guarantor_instruments_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_instruments.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/guarantor_instruments_repository.dart';

final class GuarantorInstrumentsRepositoryImpl implements GuarantorInstrumentsRepository {
  const GuarantorInstrumentsRepositoryImpl({required this._remote});

  final GuarantorInstrumentsRemoteDatasource _remote;

  @override
  Future<Result<GuarantorInstruments>> load(GuarantorRef ref) =>
      guard(() async => (await _remote.load(ref)).toEntity());

  @override
  Future<Result<GuarantorInstruments>> save(SaveInstrumentsParams params) =>
      guard(() async => (await _remote.save(params)).toEntity());
}
