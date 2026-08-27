import 'dart:ui';

import 'package:colloborator_v3/core/theme/base_colors.dart';

class LightModeColors extends BaseColors {
  const LightModeColors();

  @override
  Color get primary => const Color.fromRGBO(0,187,49,1);
  
  @override
  Color get secondary => const Color.fromRGBO(33, 150, 243, 1);

  @override
  Color get green => const Color.fromRGBO(0,179,41,1);

  @override
  Color get blue => const Color.fromRGBO(33, 150, 243, 1);
  
  @override
  Color get red => const Color.fromRGBO(244, 67, 54, 1);
  
  @override
  Color get redSoft => const Color.fromRGBO(244, 243, 249, 1);

  @override
  Color get yellow => const Color.fromRGBO(255, 152, 0, 1);

  @override
  Color get white => const Color.fromRGBO(255, 255, 255, 1);

  @override
  Color get grey => const Color.fromRGBO(121,129,121, 1);
  
  @override
  Color get grey1 => const Color.fromRGBO(204,213,205, 1);
  
  @override
  Color get black => const Color.fromRGBO(0, 0, 0, 1);

  @override
  Color get blackSoft => const Color.fromRGBO(33, 33,33, 1);
  
  @override
  // Nega 0.55: 0.38 da matn oq fonda 2.68:1 kontrastga ega edi — WCAG AA
  // talab qiladigan 4.5:1 dan ancha past. 0.55 da 4.74:1 chiqadi.
  Color get textGraySoft => const Color.fromRGBO(0, 0, 0, 0.55);
  
  @override
  Color get textBlack => const Color.fromRGBO(19, 19, 19, 1);
  
  @override
  Color get successToast => const Color.fromRGBO(97, 191, 57, 1);
  
  @override
  Color get infoToast => const Color.fromRGBO(255, 152, 0, 1);
  
  @override
  Color get errorToast => const Color.fromRGBO(255, 76, 81, 1);

  @override
  Color get background => const Color.fromRGBO(244, 243, 249, 1);

  @override
  Color get btnBackcolor => const Color.fromRGBO(241, 242, 246, 1);

  @override
  Color get backcolor => const Color.fromRGBO(241, 242, 246, 1);

  @override
  Color get stroke => const Color.fromRGBO(229, 229, 229, 1);

  @override
  Color get iconColor => const Color.fromRGBO(33, 33, 33, 1);
  
  @override
  Color get greenSoft => const Color.fromRGBO(101, 196, 102, 1);

  @override
  Color get lineColor => const Color.fromRGBO(229, 229, 229, 1);

  @override
  Color get primarySoft => const Color.fromRGBO(1, 192, 0, 1);

  @override
  Color get chartColor1 => const Color.fromRGBO(255, 209, 102, .9);

  @override
  Color get chartColor2 => const Color.fromRGBO(0, 187, 49, 1);

  @override
  Color get chartColor3 => const Color.fromRGBO(72, 207, 169, 1);

  @override
  Color get chartColor4 => const Color.fromRGBO(50, 152, 77, .9);

}