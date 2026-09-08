import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shartnoma oqimidagi har qanday server yozuvining qolipi.
///
/// Oqim tranzaksiyasiz: o'nlab mustaqil yozuv bir-birining ortidan ketadi.
/// Ikkita qoida hammasida bir xil bo'lishi shart va shuning uchun shu yerda
/// qulflangan:
///
/// 1. **Mahalliy holat faqat `Ok` dan keyin o'zgaradi.** [onOk] boshqa hech
///    qayerdan chaqirilmaydi, ya'ni "oldindan qo'llash" ni yozib bo'lmaydi.
/// 2. **Muvaffaqiyatsiz amal eslab qolinadi.** Aks holda "Qayta urinish"
///    tugmasi bosiladi va hech nima qilmaydi (5.8).
mixin ContractWriteMixin<E extends Object, S> on Bloc<E, S> {
  E? _lastWrite;

  /// Oxirgi muvaffaqiyatsiz yozuv. State'da emas — u ko'rsatilmaydi.
  E? get lastWrite => _lastWrite;

  Future<void> write<T>({
    required E event,
    required Emitter<S> emit,
    required S busy,
    required Future<Result<T>> Function() run,
    required S Function(T value) onOk,
    required S Function(Failure failure) onFailure,
  }) async {
    _lastWrite = event;
    emit(busy);

    final Result<T> result = await run();
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final T value):
        _lastWrite = null;
        emit(onOk(value));
      case Err(: final Failure failure):
        emit(onFailure(failure));
    }
  }

  /// Oxirgi muvaffaqiyatsiz amalni qaytadan yuboradi.
  ///
  /// `false` qaytsa — xato yozuvda emas, yuklashda bo'lgan; chaqiruvchi o'z
  /// yuklash eventini yuboradi.
  bool retryLastWrite() {
    final E? last = _lastWrite;
    if (last == null) return false;

    add(last);

    return true;
  }

  void forgetLastWrite() => _lastWrite = null;
}
