import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('strictList', () {
    test('barcha yozuv to‘g‘ri bo‘lsa ro‘yxat qaytadi', () {
      final result = JsonParser.strictList(
        <dynamic>[
          <String, dynamic>{'id': 1},
          <String, dynamic>{'id': 2},
        ],
        fromJson: (json) => json['id'] as int,
      );

      expect(result, [1, 2]);
    });

    test('bitta yozuv buzuq bo‘lsa butun ro‘yxat yiqiladi', () {
      expect(
        () => JsonParser.strictList(
          <dynamic>[
            <String, dynamic>{'id': 1},
            <String, dynamic>{'name': 'id siz'},
          ],
          fromJson: (json) => json['id'] as int,
        ),
        throwsA(isA<TypeError>()),
      );
    });

    test('ro‘yxat emas — yiqiladi', () {
      expect(
        () => JsonParser.strictList(<String, dynamic>{}, fromJson: (json) => json['id'] as int),
        throwsFormatException,
      );
    });

    test('element obyekt emas — yiqiladi', () {
      expect(
        () => JsonParser.strictList(<dynamic>[1, 2], fromJson: (json) => json['id'] as int),
        throwsFormatException,
      );
    });
  });
}
