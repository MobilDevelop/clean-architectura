import 'dart:io';

import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/utils/camera_issue.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/add_product_usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/catalog_usecases.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bloc/product_picker/product_picker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fake_repository.dart';

void main() {
  late FakeContractCreateRepository repository;

  ProductPickerBloc build() => ProductPickerBloc(
    suppliers: GetSuppliersUsecase(repository),
    categories: GetCategoriesUsecase(repository),
    brands: GetBrandsUsecase(repository),
    variants: GetVariantsUsecase(repository),
    scanImei: ScanImeiUsecase(repository),
  );

  const CatalogItem variant = CatalogItem(id: 9, name: 'iPhone 15');
  final File shot = File('yorliq.jpg');

  setUp(() => repository = FakeContractCreateRepository());

  test('rasmdan o‘qilgan ro‘yxat eskisini butunligicha almashtiradi', () async {
    final ProductPickerBloc bloc = build();
    repository.scanResult = const Ok<List<String>>(<String>['111111111111111']);

    bloc
      ..add(const VariantSelected(variant))
      ..add(ImeiScanned(shot));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    repository.scanResult = const Ok<List<String>>(<String>['222222222222222', '333333333333333']);
    bloc.add(ImeiScanned(shot));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(bloc.state.draft.imeis, <String>['222222222222222', '333333333333333']);
    expect(repository.lastScan?.variantId, 9);
    expect(bloc.state.isScanning, isFalse);
    await bloc.close();
  });

  test('tovar almashsa oldingi qurilmaning IMEI‘lari qolmaydi', () async {
    final ProductPickerBloc bloc = build();
    repository.scanResult = const Ok<List<String>>(<String>['111111111111111']);

    bloc
      ..add(const VariantSelected(variant))
      ..add(ImeiScanned(shot));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    bloc.add(const VariantSelected(CatalogItem(id: 10, name: 'Samsung S24')));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(bloc.state.draft.imeis, isEmpty);
    expect(bloc.state.draft.variant?.id, 10);
    await bloc.close();
  });

  test('tovar tanlanmasa so‘rov ketmaydi, sabab maydonda ko‘rinadi', () async {
    final ProductPickerBloc bloc = build();

    bloc.add(ImeiScanned(shot));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(repository.scanCalls, 0);
    expect(bloc.state.issue, ProductDraftIssue.variantMissing);
    await bloc.close();
  });

  test('xato ko‘rinadi, ro‘yxat o‘zgarmaydi', () async {
    final ProductPickerBloc bloc = build();
    repository.scanResult = const Err<List<String>>(NetworkFailure('aloqa yo`q'));

    bloc
      ..add(const VariantSelected(variant))
      ..add(ImeiScanned(shot));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(bloc.state.draft.imeis, isEmpty);
    expect(bloc.state.failure, isA<NetworkFailure>());
    expect(bloc.state.isScanning, isFalse);
    await bloc.close();
  });

  test('javob kelguncha tovar almashsa, raqamlar yangisiga yopishmaydi', () async {
    final ProductPickerBloc bloc = build();
    repository.scanDelay = const Duration(milliseconds: 40);
    repository.scanResult = const Ok<List<String>>(<String>['111111111111111']);

    bloc
      ..add(const VariantSelected(variant))
      ..add(ImeiScanned(shot));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    bloc.add(const VariantSelected(CatalogItem(id: 10, name: 'Samsung S24')));
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(bloc.state.draft.imeis, isEmpty);
    expect(bloc.state.isScanning, isFalse);
    await bloc.close();
  });

  test('skan ketayotganda olingan yangi surat eskisining o‘rnini egallaydi', () async {
    final ProductPickerBloc bloc = build();
    repository.scanDelay = const Duration(milliseconds: 40);
    repository.scanResult = const Ok<List<String>>(<String>['111111111111111']);

    bloc
      ..add(const VariantSelected(variant))
      ..add(ImeiScanned(shot));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    repository.scanResult = const Ok<List<String>>(<String>['222222222222222']);
    bloc.add(ImeiScanned(File('yorliq2.jpg')));
    await Future<void>.delayed(const Duration(milliseconds: 120));

    expect(repository.scanCalls, 2);
    expect(bloc.state.draft.imeis, <String>['222222222222222']);
    await bloc.close();
  });

  test('skan ketayotganda «Qo‘shish» yopmaydi', () async {
    final ProductPickerBloc bloc = build();
    repository.scanDelay = const Duration(milliseconds: 60);
    repository.scanResult = const Ok<List<String>>(<String>['111111111111111']);

    bloc
      ..add(const SupplierSelected(CatalogItem(id: 1, name: 'A')))
      ..add(const CategorySelected(ProductCategory(id: 2, name: 'Telefon', requiresImei: true)))
      ..add(const VariantSelected(variant))
      ..add(const PriceChanged(5000000))
      ..add(ImeiScanned(shot));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    bloc.add(const SubmitRequested());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(bloc.state.isReady, isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(bloc.state.draft.imeis, <String>['111111111111111']);
    await bloc.close();
  });

  test('kamera ochilmasa sabab ekranga chiqadi', () async {
    final ProductPickerBloc bloc = build();

    bloc.add(const CameraRefused(CameraIssue.denied));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(bloc.state.cameraIssue, CameraIssue.denied);
    expect(CameraIssueText.of(bloc.state.cameraIssue), isNotNull);
    await bloc.close();
  });

  test('ikki SIM‘li telefon bitta dona bo‘lib yoziladi', () async {
    final ProductPickerBloc bloc = build();
    repository.scanResult = const Ok<List<String>>(<String>['111111111111111', '222222222222222']);

    bloc
      ..add(const SupplierSelected(CatalogItem(id: 1, name: 'A')))
      ..add(const CategorySelected(ProductCategory(id: 2, name: 'Telefon', requiresImei: true)))
      ..add(const VariantSelected(variant))
      ..add(const PriceChanged(5000000))
      ..add(ImeiScanned(shot));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(bloc.state.draft.imeis.length, 2);
    expect(bloc.state.draft.effectiveCount, 1);
    expect(bloc.state.draft.total, 5000000);
    await bloc.close();
  });

  test('toifa almashsa kiritilgan miqdor saqlanadi', () {
    const ProductDraft draft = ProductDraft(price: 1000000, count: 5);

    expect(draft.withCategory(const ProductCategory(id: 3, name: 'Maishiy', requiresImei: false)).count, 5);
    expect(draft.withSupplier(const CatalogItem(id: 4, name: 'B')).count, 5);
    expect(draft.withBrand(const CatalogItem(id: 5, name: 'LG')).count, 5);
  });

  test('qayta urinish oxirgi suratni takrorlaydi', () async {
    final ProductPickerBloc bloc = build();
    repository.scanResult = const Err<List<String>>(NetworkFailure('aloqa yo`q'));

    bloc
      ..add(const VariantSelected(variant))
      ..add(ImeiScanned(shot));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    repository.scanResult = const Ok<List<String>>(<String>['333333333333333']);
    bloc.add(const ScanRetried());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(repository.scanCalls, 2);
    expect(bloc.state.draft.imeis, <String>['333333333333333']);
    expect(bloc.state.failure, isNull);
    await bloc.close();
  });
}
