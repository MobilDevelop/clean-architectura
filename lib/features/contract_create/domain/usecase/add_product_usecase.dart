import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/add_product_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_create_repository.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/special_tariff_repository.dart';

/// Tovar qo'shadi va qatorning id sini qaytaradi.
///
/// Tovar o'zgarsa shartnoma summasi o'zgaradi va biriktirilgan maxsus tarif
/// amal qilmay qoladi — flex ham har qo'shishda uni bekor qiladi. Bekor
/// qilishning natijasi tekshirilmaydi: markaz ekrani `GET loans/{id}` ni qayta
/// so'raydi va tarif qatorida server nima desa o'shani ko'rsatadi, ya'ni
/// muvaffaqiyatsizlik yashirinib qolmaydi (5.8).
final class AddProductUsecase implements UseCase<int, AddProductParams> {
  const AddProductUsecase(this._repository, this._tariffs);

  final ContractCreateRepository _repository;
  final SpecialTariffRepository _tariffs;

  @override
  Future<Result<int>> call(AddProductParams params) async {
    final Result<int> added = await _repository.addProduct(params);

    if (added is Err<int>) return added;

    await _tariffs.remove(params.contractId);

    return added;
  }
}

/// Qoralama yaratadi. Birinchi tovar qo'shilganda chaqiriladi — ekran
/// ochilganda emas, aks holda tashlab ketilgan har bir urinish shartnomalar
/// ro'yxatida axlat qator qoldirardi.
final class CreateDraftUsecase implements UseCase<int, int> {
  const CreateDraftUsecase(this._repository);

  final ContractCreateRepository _repository;

  @override
  Future<Result<int>> call(int params) => _repository.createDraft(params);
}

/// IMEI'ni rasmdan o'qiydi.
final class ScanImeiUsecase implements UseCase<List<String>, ScanImeiParams> {
  const ScanImeiUsecase(this._repository);

  final ContractCreateRepository _repository;

  @override
  Future<Result<List<String>>> call(ScanImeiParams params) => _repository.scanImei(params);
}
