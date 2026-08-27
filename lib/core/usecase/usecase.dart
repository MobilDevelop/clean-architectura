import 'package:colloborator_v3/core/result/result.dart';

// Bitta biznes amali: kirish `Params`, chiqish `Result<T>`.
// `call` nomi tufayli usecaseni funksiya kabi chaqirish mumkin: `loginUseCase(params)`.
abstract interface class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

// Parametr talab qilmaydigan usecase'lar uchun
final class NoParams {
  const NoParams();
} 