import 'dart:io';

import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/payment_schedule.dart';
import 'package:colloborator_v3/features/contract_create/presentation/schedule/schedule_date_text.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// To'lov jadvalini mijozga yuboriladigan PDF ga aylantiradi.
///
/// Nega usecase emas: bu yerda biznes qoidasi yo'q — qatorlar serverdan
/// tayyor keladi va faqat hujjatga ko'chiriladi. Ustiga shrift
/// `rootBundle` dan o'qiladi, ya'ni domainda turolmaydi (2.1).
abstract final class SchedulePdf {
  /// Ilova shrifti hujjat ichiga joylanadi: PDF ning standart shriftida `o'`,
  /// `g'` va kirill harflari to'g'ri chiqmaydi.
  static Future<pw.Font> _font(String asset) async => pw.Font.ttf(await rootBundle.load(asset));

  static Future<File> build({
    required PaymentSchedule schedule,
    required int contractId,
    required String clientName,
    required DateTime now,
  }) async {
    final pw.Document doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await _font('assets/fonts/NotoSans-Regular.ttf'),
        bold: await _font('assets/fonts/NotoSans-SemiBold.ttf'),
      ),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        // Sarlavha faqat birinchi betda: uzun jadvalda u har betda
        // takrorlanib joyni yeb ketardi. Jadval sarlavhasi esa
        // `TableHelper` tomonidan har betda qaytariladi.
        header: (pw.Context context) =>
            context.pageNumber == 1 ? _head(contractId, clientName, now) : pw.SizedBox(),
        build: (pw.Context context) => <pw.Widget>[_table(schedule)],
      ),
    );

    // Vaqtinchalik papka: fayl faqat ulashish uchun kerak, saqlanib qolishi
    // shart emas.
    final Directory dir = await getTemporaryDirectory();
    final File file = File('${dir.path}/tolov_jadvali_$contractId.pdf');

    return file.writeAsBytes(await doc.save());
  }

  static pw.Widget _head(int contractId, String clientName, DateTime now) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: <pw.Widget>[
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Text('ISHONCH', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text(
            ScheduleDateText.of(now),
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),

      pw.SizedBox(height: 4),
      pw.Divider(thickness: 0.8, color: PdfColors.grey400),

      pw.SizedBox(height: 10),
      pw.Text("To'lov jadvali", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),

      if (clientName.isNotEmpty) ...<pw.Widget>[
        pw.SizedBox(height: 6),
        pw.Text(clientName, style: const pw.TextStyle(fontSize: 11)),
      ],

      pw.SizedBox(height: 2),
      pw.Text(
        'Shartnoma № $contractId',
        style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
      ),

      pw.SizedBox(height: 14),
    ],
  );

  static pw.Widget _table(PaymentSchedule schedule) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: <pw.Widget>[
      pw.TableHelper.fromTextArray(
        headers: <String>['№', 'Sana', 'Summa'],
        data: schedule.rows
            .map(
              (ScheduleRow row) => <String>[
                '${row.number}',
                ScheduleDateText.of(row.date),
                Money.withUnit(row.amount),
              ],
            )
            .toList(),
        headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
        cellStyle: const pw.TextStyle(fontSize: 10),
        cellHeight: 22,
        headerAlignments: <int, pw.Alignment>{
          0: pw.Alignment.center,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.centerRight,
        },
        cellAlignments: <int, pw.Alignment>{
          0: pw.Alignment.center,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.centerRight,
        },
        columnWidths: <int, pw.TableColumnWidth>{
          0: const pw.FixedColumnWidth(34),
          1: const pw.FlexColumnWidth(),
          2: const pw.FixedColumnWidth(120),
        },
        border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      ),

      pw.SizedBox(height: 10),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: <pw.Widget>[
          pw.Text(
            "Jami: ${Money.withUnit(schedule.total)}",
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    ],
  );
}
