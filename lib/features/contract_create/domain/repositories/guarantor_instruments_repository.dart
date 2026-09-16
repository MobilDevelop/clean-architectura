import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_instruments.dart';

abstract interface class GuarantorInstrumentsRepository {
  Future<Result<GuarantorInstruments>> load(GuarantorRef ref);

  Future<Result<GuarantorInstruments>> save(SaveInstrumentsParams params);
}
