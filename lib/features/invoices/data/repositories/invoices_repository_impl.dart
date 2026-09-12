import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/invoices/data/datasources/invoices_remote_datasource.dart';
import 'package:colloborator_v3/features/invoices/data/models/invoice_dto.dart';
import 'package:colloborator_v3/features/invoices/domain/entities/invoice.dart';
import 'package:colloborator_v3/features/invoices/domain/repositories/invoices_repository.dart';

final class InvoicesRepositoryImpl implements InvoicesRepository {
  const InvoicesRepositoryImpl({required this._remote});

  final InvoicesRemoteDatasource _remote;

  @override
  Future<Result<InvoicesPageResult>> getInvoices(InvoicesQuery query) => guard(() async {
    final InvoicesPageDto page = await _remote.getInvoices(query);

    return InvoicesPageResult(
      items: page.items.map((InvoiceDto dto) => dto.toEntity()).toList(),
      isLast: page.isLast,
    );
  });

  @override
  Future<Result<void>> sendToPartner(int waybillId) => guard(() => _remote.sendToPartner(waybillId));
}
