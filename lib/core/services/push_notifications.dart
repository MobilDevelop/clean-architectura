import 'dart:async';

/// Push xabarining ilova o'qiydigan qismi.
///
/// `Map` emas, tipli obyekt: backend qaysi kalitlarni yuborishi shu yerda
/// ko'rinadi va kalit nomi bitta joyda turadi (`message`, `contract_id` —
/// flex `app_manager_cubit.dart:38`).
final class PushMessage {
  const PushMessage({required this.text, required this.contractId});

  factory PushMessage.fromData(Map<String, dynamic> data) => PushMessage(
    text: data['message']?.toString() ?? '',
    // Push maydonlari har doim satr bo'lib keladi, shuning uchun `as int` emas.
    contractId: int.tryParse(data['contract_id']?.toString() ?? '') ?? 0,
  );

  /// Lokal bildirishnoma faqat satr uzata oladi.
  factory PushMessage.fromPayload(String? payload) =>
      PushMessage(text: '', contractId: int.tryParse(payload ?? '') ?? 0);

  final String text;

  /// `0` — xabar biror shartnomaga tegishli emas.
  final int contractId;

  bool get hasContract => contractId > 0;

  String get payload => '$contractId';
}

/// Push xabarlarining ilova ichidagi yagona kanali.
///
/// Nega alohida klass: `FirebaseService` xabarni **oladi**, ekranlar esa unga
/// **javob beradi**. Ikkalasi bitta joyda tursa, `contracts` ekrani
/// Firebase'ga bog'lanib qolardi va uni push'siz test qilib bo'lmasdi (9.2).
final class PushNotifications {
  final StreamController<PushMessage> _received = StreamController<PushMessage>.broadcast();
  final StreamController<PushMessage> _opened = StreamController<PushMessage>.broadcast();

  /// Bosilgan, lekin hali hech kim olib ketmagan xabar.
  ///
  /// Sovuq startda bildirishnoma ilova ishga tushishidan **oldin** bosiladi:
  /// o'sha paytda `ContractsBloc` hali yaratilmagan, broadcast oqim esa
  /// xabarni saqlamaydi. Shuning uchun oxirgisi shu yerda kutib turadi.
  PushMessage? _pending;

  /// Ilova ochiq turganda kelgan xabar.
  Stream<PushMessage> get received => _received.stream;

  /// Bildirishnoma bosildi. Xabarning o'zi oqimda emas — uni `takePending`
  /// beradi, shunda ikkita tinglovchi bitta bosishni ikki marta bajarmaydi.
  Stream<PushMessage> get opened => _opened.stream;

  void receive(PushMessage message) {
    if (_received.isClosed) return;
    _received.add(message);
  }

  void open(PushMessage message) {
    _pending = message;
    if (_opened.isClosed) return;
    _opened.add(message);
  }

  /// Olib ketilmagan bosish bormi. Marshrut shuni so'raydi: xabarning o'zi
  /// unga kerak emas, u faqat ekranni almashtiradi.
  bool get hasPending => _pending != null;

  /// Kutib turgan xabarni oladi va o'chiradi — ikkinchi marta qaytmaydi.
  PushMessage? takePending() {
    final PushMessage? message = _pending;
    _pending = null;

    return message;
  }

  Future<void> dispose() async {
    await _received.close();
    await _opened.close();
  }
}
