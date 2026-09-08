import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_form.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/add_product_usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/contract_write_usecases.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/get_contract_details_usecase.dart';
import 'package:colloborator_v3/features/contract_create/presentation/products/contract_products_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fake_repository.dart';
import '_fake_tariff_repository.dart';

const ProductDraft _draft = ProductDraft(
  supplier: CatalogItem(id: 3, name: 'Ta’minotchi'),
  category: ProductCategory(id: 4, name: 'Telefon', requiresImei: false),
  brand: CatalogItem(id: 5, name: 'Brend'),
  variant: CatalogItem(id: 6, name: 'Model'),
  price: 1000000,
  count: 2,
);

ContractProductsBloc _bloc(
  FakeContractCreateRepository repo,
  FakeSpecialTariffRepository tariffs, {
  int? contractId,
}) => ContractProductsBloc(
  args: ContractCreateArgs(clientId: 42, contractId: contractId),
  getDetails: GetContractDetailsUsecase(repo),
  createDraft: CreateDraftUsecase(repo),
  addProduct: AddProductUsecase(repo, tariffs),
  updateProduct: UpdateProductUsecase(repo),
  deleteProduct: DeleteProductUsecase(repo, tariffs),
);

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 30));

void main() {
  late FakeContractCreateRepository repo;
  late FakeSpecialTariffRepository tariffs;

  setUp(() {
    repo = FakeContractCreateRepository();
    tariffs = FakeSpecialTariffRepository();
  });

  test('qoralama ekran ochilganda emas, birinchi tovar qo‘shilganda yaratiladi', () async {
    final ContractProductsBloc bloc = _bloc(repo, tariffs);

    bloc.add(const ProductsRequested());
    await _settle();
    expect(repo.draftCalls, 0);
    expect(bloc.state.contractId, isNull);

    bloc.add(const ProductAdded(_draft));
    await _settle();
    expect(repo.draftCalls, 1);
    expect(bloc.state.contractId, 77);
    expect(bloc.state.revision, 1);

    await bloc.close();
  });

  test('ikkinchi tovarda qoralama qayta yaratilmaydi', () async {
    final ContractProductsBloc bloc = _bloc(repo, tariffs);

    bloc
      ..add(const ProductAdded(_draft))
      ..add(const ProductAdded(_draft));
    await _settle();

    expect(repo.draftCalls, 1);
    expect(repo.addCalls, 2);
    expect(bloc.state.products.length, 2);

    await bloc.close();
  });

  test('tovar qo‘shilgach biriktirilgan tarif bekor qilinadi', () async {
    final ContractProductsBloc bloc = _bloc(repo, tariffs);

    bloc.add(const ProductAdded(_draft));
    await _settle();

    expect(tariffs.removeCalls, 1);

    await bloc.close();
  });

  test('tovar qo‘shish xato bersa ro‘yxat o‘zgarmaydi va tarif ham tegilmaydi', () async {
    repo.addResult = const Err<int>(ServerFailure('server'));
    final ContractProductsBloc bloc = _bloc(repo, tariffs);

    bloc.add(const ProductAdded(_draft));
    await _settle();

    expect(bloc.state.products, isEmpty);
    expect(bloc.state.failure, isA<ServerFailure>());
    expect(bloc.state.write, ProductWrite.none);
    expect(tariffs.removeCalls, 0);

    await bloc.close();
  });

  test('qayta urinish oxirgi muvaffaqiyatsiz amalni takrorlaydi', () async {
    repo.addResult = const Err<int>(NetworkFailure('aloqa'));
    final ContractProductsBloc bloc = _bloc(repo, tariffs);

    bloc.add(const ProductAdded(_draft));
    await _settle();
    expect(repo.addCalls, 1);

    repo.addResult = const Ok<int>(9);
    bloc.add(const Retried());
    await _settle();

    expect(repo.addCalls, 2);
    expect(bloc.state.products.single.id, 9);
    expect(bloc.state.failure, isNull);

    await bloc.close();
  });

  test('qoralama yaratilmasa qayta urinish qo‘shishni takrorlaydi', () async {
    repo.draftResult = const Err<int>(ClientFailure('mijozda ochiq shartnoma bor'));
    final ContractProductsBloc bloc = _bloc(repo, tariffs);

    bloc.add(const ProductAdded(_draft));
    await _settle();

    expect(repo.addCalls, 0);
    expect(bloc.state.contractId, isNull);
    expect(bloc.state.failure, isA<ClientFailure>());

    repo.draftResult = const Ok<int>(77);
    bloc.add(const Retried());
    await _settle();

    expect(repo.draftCalls, 2);
    expect(repo.addCalls, 1);
    expect(bloc.state.products.length, 1);

    await bloc.close();
  });

  test('o‘chirish xato bersa qator joyida qoladi', () async {
    repo.deleteResult = const Err<void>(ServerFailure('server'));
    final ContractProductsBloc bloc = _bloc(repo, tariffs);

    bloc.add(const ProductAdded(_draft));
    await _settle();
    final int id = bloc.state.products.single.id;

    bloc.add(ProductRemoved(id));
    await _settle();

    expect(repo.deleteCalls, 1);
    expect(bloc.state.products.length, 1);
    expect(bloc.state.failure, isA<ServerFailure>());
    expect(bloc.state.busyProductId, id);

    await bloc.close();
  });

  test('narx va miqdorni saqlash server tasdiqlagach ro‘yxatga tushadi', () async {
    final ContractProductsBloc bloc = _bloc(repo, tariffs);

    bloc.add(const ProductAdded(_draft));
    await _settle();
    final int id = bloc.state.products.single.id;

    repo.updateResult = const Err<void>(ClientFailure('narx'));
    bloc.add(ProductSaved(productId: id, price: 7, count: 3));
    await _settle();
    expect(bloc.state.products.single.price, 1000000);

    repo.updateResult = const Ok<void>(null);
    bloc.add(const Retried());
    await _settle();

    expect(bloc.state.products.single.price, 7);
    expect(bloc.state.products.single.count, 3);
    expect(repo.lastUpdate?.supplierId, 3);

    await bloc.close();
  });
}
