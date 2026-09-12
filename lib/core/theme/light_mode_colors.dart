import 'dart:ui';

import 'package:colloborator_v3/core/theme/base_colors.dart';

class LightModeColors extends BaseColors {
  const LightModeColors();

  @override
  /// Figma «Primary» — yashil ramp 700 (#18B83C)
  Color get primary => const Color.fromARGB(255, 0x18, 0xB8, 0x3C);
  
  @override
  /// Ko'k urg'u rangi.
  ///
  /// Figma'dagi «Secondary» — oq (brend juftligi), ya'ni boshqa rol. Bu yerda
  /// `secondary` ekrandagi ikkinchi darajali urg'u sifatida ishlatiladi
  /// (bo'lim ikonkalari, havolalar) va Figma'ning «Info» rangi bilan bir xil.
  Color get secondary => const Color.fromARGB(255, 0x21, 0x96, 0xF3);

  @override
  /// Figma «Success» — yashil ramp 800 (#01B329)
  Color get green => const Color.fromARGB(255, 0x01, 0xB3, 0x29);

  @override
  /// Figma «Info» — ko'k ramp 800 (#2196F3)
  Color get blue => const Color.fromARGB(255, 0x21, 0x96, 0xF3);
  
  @override
  /// Figma «Error» — qizil ramp 800 (#F44336)
  Color get red => const Color.fromARGB(255, 0xF4, 0x43, 0x36);
  

  @override
  /// Figma «Warning» — sariq ramp 800 (#E7BD06). Ilgari bu #FF9800 (Material to'q sariq) edi
  Color get yellow => const Color.fromARGB(255, 0xE7, 0xBD, 0x06);

  @override
  Color get white => const Color.fromRGBO(255, 255, 255, 1);

  @override
  /// Figma kulrang ramp 600 (#888888). Ilgari #798179 — yashilga moyil kulrang edi
  Color get grey => const Color.fromARGB(255, 0x88, 0x88, 0x88);
  
  @override
  /// Figma kulrang ramp 300 (#D3D3D3). Ilgari #CCD5CD — yashilga moyil edi
  Color get grey1 => const Color.fromARGB(255, 0xD3, 0xD3, 0xD3);
  
  @override
  Color get black => const Color.fromRGBO(0, 0, 0, 1);

  @override
  /// Figma kulrang ramp 800 (#212121)
  Color get blackSoft => const Color.fromARGB(255, 0x21, 0x21, 0x21);
  
  @override
  // Nega 0.55: 0.38 da matn oq fonda 2.68:1 kontrastga ega edi — WCAG AA
  // talab qiladigan 4.5:1 dan ancha past. 0.55 da 4.74:1 chiqadi.
  Color get textGraySoft => const Color.fromRGBO(0, 0, 0, 0.55);
  
  @override
  /// Figma kulrang ramp 900 (#111111)
  Color get textBlack => const Color.fromARGB(255, 0x11, 0x11, 0x11);
  
  @override
  Color get successToast => const Color.fromRGBO(97, 191, 57, 1);
  
  @override
  Color get infoToast => const Color.fromRGBO(255, 152, 0, 1);
  
  @override
  Color get errorToast => const Color.fromRGBO(255, 76, 81, 1);

  @override
  Color get background => const Color.fromRGBO(244, 243, 249, 1);

  @override
  /// Figma kulrang ramp 100 (#F1F1F1)
  Color get btnBackcolor => const Color.fromARGB(255, 0xF1, 0xF1, 0xF1);

  @override
  /// Figma «Background / Primary» (#F4F3F9). Ilgari #F1F2F6 edi
  Color get backcolor => const Color.fromARGB(255, 0xF4, 0xF3, 0xF9);

  @override
  /// Figma kulrang ramp 200 (#E2E2E2)
  Color get stroke => const Color.fromARGB(255, 0xE2, 0xE2, 0xE2);

  

  @override
  /// Figma yashil ramp 600 (#4DCA69) — `primary` bilan gradiyent juftligi
  Color get primarySoft => const Color.fromARGB(255, 0x4D, 0xCA, 0x69);

}