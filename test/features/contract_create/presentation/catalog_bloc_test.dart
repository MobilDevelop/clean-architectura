import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/paged.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/catalog_query.dart';
import 'package:colloborator_v3/features/contract_create/presentation/picker/catalog_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('birinchi yuklash ro‘yxatni to‘ldiradi', () async {
    final CatalogBloc<String> bloc = CatalogBloc<String>(
      load: (CatalogQuery q) async => Ok<Paged<String>>(Paged<String>(items: <String>['a', 'b'], isLast: false)),
    );

    bloc.add(const CatalogSearched('', debounce: false));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(bloc.state.items, <String>['a', 'b']);
    expect(bloc.state.isLast, isFalse);
    await bloc.close();
  });

  test('keyingi sahifa qo‘shiladi, almashtirmaydi', () async {
    int page = 0;
    final CatalogBloc<String> bloc = CatalogBloc<String>(
      load: (CatalogQuery q) async {
        page = q.page;
        return Ok<Paged<String>>(Paged<String>(items: <String>['s$page'], isLast: false));
      },
    );

    bloc.add(const CatalogSearched('', debounce: false));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    bloc.add(const CatalogNextPage());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(bloc.state.items, <String>['s1', 's2']);
    expect(bloc.state.page, 2);
    await bloc.close();
  });

  test('oxirgi sahifadan keyin so‘rov yuborilmaydi', () async {
    int calls = 0;
    final CatalogBloc<String> bloc = CatalogBloc<String>(
      load: (CatalogQuery q) async {
        calls++;
        return const Ok<Paged<String>>(Paged<String>.last(<String>['a']));
      },
    );

    bloc.add(const CatalogSearched('', debounce: false));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    bloc.add(const CatalogNextPage());
    bloc.add(const CatalogNextPage());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(calls, 1);
    await bloc.close();
  });

  test('xato ro‘yxatni o‘chirmaydi', () async {
    bool first = true;
    final CatalogBloc<String> bloc = CatalogBloc<String>(
      load: (CatalogQuery q) async {
        if (first) {
          first = false;
          return Ok<Paged<String>>(Paged<String>(items: <String>['a'], isLast: false));
        }
        return const Err<Paged<String>>(NetworkFailure('yo‘q'));
      },
    );

    bloc.add(const CatalogSearched('', debounce: false));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    bloc.add(const CatalogNextPage());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(bloc.state.items, <String>['a']);
    expect(bloc.state.failure, isA<NetworkFailure>());
    await bloc.close();
  });
}
