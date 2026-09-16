import 'package:colloborator_v3/core/utils/client_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pasport yorliqsiz, INPS yorliq bilan', () {
    expect(
      ClientIdentity.line(passport: 'AB1234567', inps: '31201000560012'),
      'AB1234567  ·  INPS 31201000560012',
    );
  });

  test('bittasi bo‘lmasa ajratuvchi qolmaydi', () {
    expect(ClientIdentity.line(passport: 'AB1234567', inps: ''), 'AB1234567');
    expect(ClientIdentity.line(passport: '', inps: '31201000560012'), 'INPS 31201000560012');
  });

  test('ikkalasi ham bo‘lmasa qator bo‘sh', () {
    expect(ClientIdentity.line(passport: '', inps: ''), isEmpty);
  });
}
