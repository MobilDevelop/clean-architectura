import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:colloborator_v3/features/invoices/data/models/invoice_dto.dart';
import 'package:colloborator_v3/features/invoices/domain/entities/invoice.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _from(Map<String, dynamic> json) => InvoiceDto.fromJson(json).toEntity();

void main() {
  test('to‘liq javob o‘qiladi', () {
    final Invoice invoice = _from(<String, dynamic>{
      'id': 12,
      'contract_id': 36555548,
      'value': '1800000',
      'partner': <String, dynamic>{'id': 3, 'name': 'Ishonch savdo MChJ'},
      'status': <String, dynamic>{'id': 15, 'key': 'invoice_created'},
      'waybill_id': 77,
      'waybill_url': 'https://example.test/77.pdf',
    });

    expect(invoice.id, 12);
    expect(invoice.contractId, 36555548);
    expect(invoice.price, 1800000);
    expect(invoice.partnerName, 'Ishonch savdo MChJ');
    expect(invoice.status, ContractStatus.invoiceCreated);
    expect(invoice.waybillId, 77);
    expect(invoice.canOpen, isTrue);
    expect(invoice.canSend, isTrue);
  });

  // Flex `json['status']['id']` deb o'qiydi: `status` kelmasa butun ro'yxat
  // parse paytida yiqilib, ekran «Ma'lumot topilmadi» deb turib qolardi.
  test('ichma-ich obyektlar kelmasa yozuv yiqilmaydi', () {
    final Invoice invoice = _from(<String, dynamic>{'id': 12, 'contract_id': 5});

    expect(invoice.partnerName, '');
    expect(invoice.status, ContractStatus.unknown);
    expect(invoice.price, 0);
  });

  // Summa satr bo'lib keladi va kasr qismi ham bo'lishi mumkin.
  test('kasrli summa butun so‘mga aylanadi', () {
    expect(_from(<String, dynamic>{'value': '1800000.00'}).price, 1800000);
    expect(_from(<String, dynamic>{'value': 1800000}).price, 1800000);
  });

  // Fayl ham, yuk xati yozuvi ham bo'lmasligi mumkin — o'shanda amal
  // ochilmaydi va sababi ekranda aytiladi (5.8).
  test('fayl va yuk xati yo‘qligi bilinadi', () {
    final Invoice invoice = _from(<String, dynamic>{'id': 1});

    expect(invoice.canOpen, isFalse);
    expect(invoice.canSend, isFalse);
  });
}
