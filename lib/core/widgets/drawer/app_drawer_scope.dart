import 'package:flutter/widgets.dart';

/// Yon menyuni ochish yo'li.
///
/// Nega kerak: menyu **shell** ning `Scaffold` ida turadi, ya'ni u pastki
/// panel ustiga ham chiqadi. Ekranlarning o'z `Scaffold` i esa shellning
/// ichida — `Scaffold.of(context)` ulardan yuqoriga chiqa olmaydi va o'z
/// Scaffold'ini topadi.
///
/// Nega global kalit emas: bu yo'l daraxt orqali beriladi, ya'ni testda
/// almashtirish mumkin va ikkita shell bo'lsa ham chalkashmaydi.
final class AppDrawerScope extends InheritedWidget {
  const AppDrawerScope({super.key, required this.open, required super.child});

  final VoidCallback open;

  /// Menyu yo'q joyda `null` — masalan shelldan tashqarida ochilgan ekranda.
  static VoidCallback? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppDrawerScope>()?.open;

  @override
  bool updateShouldNotify(AppDrawerScope oldWidget) => open != oldWidget.open;
}
