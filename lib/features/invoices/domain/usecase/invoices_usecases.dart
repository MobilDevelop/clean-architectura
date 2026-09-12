import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/invoices/domain/entities/invoice.dart';
import 'package:colloborator_v3/features/invoices/domain/repositories/invoices_repository.dart';

final class GetInvoicesUsecase implements UseCase<InvoicesPageResult, InvoicesQuery> {
  const GetInvoicesUsecase(this._repository);

  final InvoicesRepository _repository;

  @override
  Future<Result<InvoicesPageResult>> call(InvoicesQuery params) => _repository.getInvoices(params);
}

final class SendInvoiceUsecase implements UseCase<void, int> {
  const SendInvoiceUsecase(this._repository);

  final InvoicesRepository _repository;

  /// Yuk xati yozuvisiz so'rov yuborilmaydi: manzilda `0` bilan ketgan so'rov
  /// serverda rad etilib, xodimga umumiy xato ko'rinardi.
  @override
  Future<Result<void>> call(int params) async {
    if (params == 0) {
      return const Err<void>(ClientFailure("Bu fakturaning yuk xati yo'q"));
    }

    return _repository.sendToPartner(params);
  }
}
