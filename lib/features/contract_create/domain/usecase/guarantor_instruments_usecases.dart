import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_instruments.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/guarantor_instruments_repository.dart';

final class LoadInstrumentsUsecase implements UseCase<GuarantorInstruments, GuarantorRef> {
  const LoadInstrumentsUsecase(this._repository);

  final GuarantorInstrumentsRepository _repository;

  @override
  Future<Result<GuarantorInstruments>> call(GuarantorRef ref) => _repository.load(ref);
}

final class SaveInstrumentsUsecase implements UseCase<GuarantorInstruments, SaveInstrumentsParams> {
  const SaveInstrumentsUsecase(this._repository);

  final GuarantorInstrumentsRepository _repository;

  @override
  Future<Result<GuarantorInstruments>> call(SaveInstrumentsParams params) => _repository.save(params);
}
