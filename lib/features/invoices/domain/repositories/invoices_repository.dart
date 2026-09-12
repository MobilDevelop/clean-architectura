import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/invoices/domain/entities/invoice.dart';

abstract interface class InvoicesRepository {
  Future<Result<InvoicesPageResult>> getInvoices(InvoicesQuery query);

  /// Yuk xatini ta'minotchiga yuboradi.
  Future<Result<void>> sendToPartner(int waybillId);
}
