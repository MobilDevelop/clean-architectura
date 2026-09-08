import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/pull_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// `true` — yuklanmoqda.
final class _LoadCubit extends Cubit<bool> {
  _LoadCubit() : super(false);

  int starts = 0;

  void start() {
    starts++;
    emit(true);
  }

  void finish() => emit(false);
}

Widget _app(_LoadCubit cubit) => MaterialApp(
  home: BlocProvider<_LoadCubit>.value(
    value: cubit,
    child: Scaffold(
      body: PullRefresh<_LoadCubit, bool>(
        isLoading: (bool state) => state,
        refreshPress: cubit.start,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[SizedBox(height: 800, child: Container(color: Colors.white))],
        ),
      ),
    ),
  ),
);

/// Tortib qo'yib yuboradi va indikator ishga tushishini kutadi.
Future<void> _pull(WidgetTester tester) async {
  await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  // `AppTheme.colors` — ilova ishga tushganda to'ldiriladigan `late` maydon.
  // To'liq `init()` ekran o'lchamini talab qiladi, bu yerda faqat ranglar kerak.
  setUpAll(() => AppTheme.colors = AppTheme.getThemeColors(ThemeMode.light));

  testWidgets('tortish yangilash eventini yuboradi', (WidgetTester tester) async {
    final _LoadCubit cubit = _LoadCubit();
    await tester.pumpWidget(_app(cubit));

    await _pull(tester);

    expect(cubit.starts, 1);

    cubit.finish();
    await tester.pumpAndSettle();
    await cubit.close();
  });

  testWidgets('indikator yuklash tugagunicha turadi', (WidgetTester tester) async {
    final _LoadCubit cubit = _LoadCubit();
    await tester.pumpWidget(_app(cubit));

    await _pull(tester);

    // Yuklash hali tugamagan — indikator ekranda qolishi shart. Aks holda
    // foydalanuvchi yangilanish bo'ldi deb o'ylaydi.
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);

    cubit.finish();
    await tester.pumpAndSettle();

    expect(find.byType(RefreshProgressIndicator), findsNothing);
    await cubit.close();
  });
}
