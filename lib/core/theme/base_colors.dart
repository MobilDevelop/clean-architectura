import 'dart:ui';

abstract class BaseColors {
  const BaseColors();
  
  // Primary colors
  Color get primary;
  Color get secondary;
  Color get green;
  Color get blue;
  Color get red;
  Color get yellow;

  // UI colors
  Color get stroke;
  Color get backcolor;
  Color get btnBackcolor;
  Color get white;
  Color get grey;
  Color get grey1;
  Color get black;
  Color get blackSoft;
  Color get primarySoft;

  // Text colors
  Color get textGraySoft;
  Color get textBlack;

  // Toast colors
  Color get infoToast;
  Color get successToast;
  Color get errorToast;

  // Chart colors

  // Background
  Color get background;
}
