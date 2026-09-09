import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_data.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_forms.dart';

/// `POST/PUT underwriters` tanasi.
///
/// `sealed` forma tufayli yangi bo'lim qo'shilsa bu `switch` kompilyatsiyada
/// xato beradi — ya'ni tanani yozishni unutib bo'lmaydi (O — Open/Closed).
Map<String, dynamic> underwriterBody(SaveUnderwriterParams params) {
  final UnderwriterForm form = params.form;

  final Map<String, dynamic> body = <String, dynamic>{
    'type': form.kind.code,
    'contract_id': params.args.contractId,
    'client_id': params.args.clientId,
    'file_urls': form.files.map((e) => e.key).toList(),
  };

  switch (form) {
    case SalaryForm(: final List<SalaryRow> rows):
      body['sum'] = rows
          .map((SalaryRow e) => <String, dynamic>{'year': e.year, 'month': e.month, 'salary': e.amount})
          .toList();

    case PensionForm(: final int amount):
      body['sum'] = amount;

    case StudentForm():
      // Talaba bo'limida summa yo'q, lekin server maydonni kutadi.
      body['sum'] = 0;

    case MilitaryForm(: final position):
      body['rank_id'] = position.id;
      // Summa lavozimdan keladi, foydalanuvchidan emas.
      body['sum'] = position.amount;

    case CarForm(: final brand, : final model, : final int year):
      body['car_brand_id'] = brand.id;
      body['car_model_id'] = model.id;
      // Server yilni satr sifatida kutadi.
      body['manufacture_year'] = "$year";
  }

  return body;
}
