import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/network/paged_response.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/invoices/data/models/invoice_dto.dart';
import 'package:colloborator_v3/features/invoices/domain/entities/invoice.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

/// Sahifa javobi: yozuvlar va bu oxirgi sahifami.
typedef InvoicesPageDto = ({List<InvoiceDto> items, bool isLast});

final class InvoicesRemoteDatasource {
  InvoicesRemoteDatasource({required this._dio, required this._now});

  final Dio _dio;

  /// Sana tashqaridan: filtr qo'yilmasa bugungi kun olinadi va test bugun
  /// o'tib ertaga yiqilmasligi kerak (9.4).
  final DateTime Function() _now;

  static final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  /// So'rov `dynamic` bilan yuboriladi: `get<Map<String, dynamic>>` javob
  /// boshqa shaklda kelganda Dio ichida, interceptor zanjiridan **keyin**
  /// yiqiladi va nosozlik botga yetib bormaydi.
  Future<InvoicesPageDto> getInvoices(InvoicesQuery query) async {
    final Response<dynamic> result = await _dio.get<dynamic>(
      Endpoints.invoices,
      queryParameters: <String, dynamic>{
        'date': _formatter.format(query.date ?? _now()),
        'page': query.page,
        'per_page': InvoicesQuery.perPage,
        'is_mobile': true,
      },
    );

    final Object? body = result.data;
    final Map<String, dynamic> json = body is Map<String, dynamic> ? body : const <String, dynamic>{};

    final List<InvoiceDto> items = JsonParser.list(json['data'], fromJson: InvoiceDto.fromJson);

    return (
      items: items,
      isLast: PagedResponse.isLast(
        json: json,
        received: items.length,
        page: query.page,
        perPage: InvoicesQuery.perPage,
      ),
    );
  }

  Future<void> sendToPartner(int waybillId) async {
    await _dio.post<dynamic>('${Endpoints.waybills}$waybillId/send-to-partner');
  }
}
