import 'package:colloborator_v3/features/underwriter/data/models/underwriter_dto.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// `GET underwriters` javobining shakli flex'dan olingan
/// (`certificate_edit.dart:21`, `military_model.dart:15`, `auto_income.dart:63`).
///
/// Kalitlar assimetrik: lavozim **ichma-ich** `rank` obyektida keladi, lekin
/// yuborishda tekis `rank_id` bo'lib ketadi; avtomobilda id `car_brand_id`,
/// nomi esa `brand_name`. Shu farq bir marta noto'g'ri yozilgan edi va
/// saqlangan lavozim ekranga hech qachon qaytmasdi.
void main() {
  test('guvohnoma lavozimi `rank` obyektidan o‘qiladi', () {
    final UnderwriterData data = UnderwriterDataDto.fromJson(<String, dynamic>{
      'military': <String, dynamic>{
        'id': 31,
        'urls': <String>['s3/a.pdf'],
        'rank': <String, dynamic>{'id': 7, 'name': 'Serjant', 'amount': 4500000},
      },
    }).toEntity();

    expect(data.military.editId, 31);
    expect(data.military.position.id, 7);
    expect(data.military.position.name, 'Serjant');
    expect(data.military.position.amount, 4500000);
    expect(data.military.files.length, 1);
  });

  test('avtomobil brendi va markasi `brand_name` / `model_name` dan o‘qiladi', () {
    final UnderwriterData data = UnderwriterDataDto.fromJson(<String, dynamic>{
      'car': <String, dynamic>{
        'id': 44,
        'urls': <String>[],
        'car_brand_id': 3,
        'brand_name': 'Chevrolet',
        'car_model_id': 12,
        'model_name': 'Cobalt',
        'manufacture_year': 2019,
      },
    }).toEntity();

    expect(data.car.editId, 44);
    expect(data.car.brand.id, 3);
    expect(data.car.brand.name, 'Chevrolet');
    expect(data.car.model.id, 12);
    expect(data.car.model.name, 'Cobalt');
    expect(data.car.year, 2019);
  });

  test('bo‘limlar javobda bo‘lmasa bo‘sh forma qaytadi, istisno otilmaydi', () {
    final UnderwriterData data = UnderwriterDataDto.fromJson(<String, dynamic>{}).toEntity();

    expect(data.salary.editId, 0);
    expect(data.military.position.id, 0);
    expect(data.car.brand.name, '');
  });

  // Ekran shu sababli ochilmayotgan edi: hech nima saqlanmagan shartnomada
  // server obyekt emas, bo'sh ro'yxat qaytaradi. Javob `Map<String, dynamic>`
  // deb tiplangani uchun Dio uni o'z ichida yiqitardi va — interceptor zanjiri
  // allaqachon tugagani uchun — botga ham hech nima ketmasdi.
  group('javobning yuqori darajasi', () {
    test('bo‘sh ro‘yxat — hali hech nima saqlanmagan, xato emas', () {
      expect(UnderwriterDataDto.tryFrom(const <dynamic>[]), isNull);
    });

    test('`null` ham hech nima saqlanmagan', () {
      expect(UnderwriterDataDto.tryFrom(null), isNull);
    });

    test('obyekt o‘qiladi', () {
      final UnderwriterDataDto? dto = UnderwriterDataDto.tryFrom(<String, dynamic>{
        'pension': <String, dynamic>{'id': 9, 'sum': 1500000},
      });

      expect(dto?.toEntity().pension.editId, 9);
      expect(dto?.toEntity().pension.amount, 1500000);
    });

    // Buzuq javob jimgina "bo'sh" ga aylantirilmaydi (5.8): aks holda
    // to'ldirilgan bo'limlar ekranda yo'q bo'lib ko'rinardi va foydalanuvchi
    // ularni ikkinchi marta yozib, serverda ikkinchi yozuv qoldirardi.
    test('kutilmagan shakl — `FormatException`, bo‘sh forma emas', () {
      expect(() => UnderwriterDataDto.tryFrom('<html>502</html>'), throwsFormatException);
      expect(() => UnderwriterDataDto.tryFrom(const <dynamic>[1, 2]), throwsFormatException);
    });
  });
}
