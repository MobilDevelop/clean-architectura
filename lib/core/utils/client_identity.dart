/// Shaxsni tanitadigan qator: pasport va INPS.
///
/// Nega bir joyda: bu qator shartnoma kartasida ham, batafsil oynasining
/// ishtirokchilar qismida ham chiqadi. Ikki joyda alohida yozilsa ular
/// asta-sekin bir-biridan uzoqlashadi.
///
/// Pasportga «Pasport» so'zi qo'shilmaydi — u qatorni 393px ekranda ikkiga
/// bo'lib yuboradi va pasport o'z shakli bilan o'zini tanitadi. INPS esa
/// yorliqsiz qolsa, yalang'och 14 xonali son nima ekani ko'rinmaydi.
abstract final class ClientIdentity {
  static String line({required String passport, required String inps}) {
    final List<String> parts = <String>[
      if (passport.isNotEmpty) passport,
      if (inps.isNotEmpty) "INPS $inps",
    ];

    return parts.join('  ·  ');
  }
}
