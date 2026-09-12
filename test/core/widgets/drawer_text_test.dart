import 'package:colloborator_v3/core/widgets/drawer/drawer_text.dart';
import 'package:flutter_test/flutter_test.dart';

/// Menyudagi bosh harflar. Rasm o'rniga ular chiziladi, shuning uchun
/// hech qanday kiritishda istisno otmasligi kerak.
void main() {
  test('ism-familiyadan ikkita harf olinadi', () {
    expect(DrawerText.initials('Abdurahmonov Abdulaziz Abdurahmonovich'), 'AA');
    expect(DrawerText.initials('Aliyev Vali'), 'AV');
  });

  test('bitta so‘zdan bitta harf', () => expect(DrawerText.initials('Aliyev'), 'A'));

  // Backend ismni bermasligi mumkin — o'shanda ham avatar chiziladi.
  test('bo‘sh ism savol belgisi beradi', () {
    expect(DrawerText.initials(''), '?');
    expect(DrawerText.initials('   '), '?');
  });

  // Ortiqcha bo'shliqlar ikkinchi harfni surib yubormasligi kerak.
  test('ortiqcha bo‘shliqlar hisobga olinmaydi', () {
    expect(DrawerText.initials('  Aliyev   Vali  '), 'AV');
  });

  test('kirill harflari ham ishlaydi', () => expect(DrawerText.initials('Алиев Вали'), 'АВ'));
}
