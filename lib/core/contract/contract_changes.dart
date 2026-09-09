import 'dart:async';

/// Shartnomalar ro'yxatida nima o'zgargani.
enum ContractChange {
  /// Ro'yxatga yangi qator qo'shildi — qoralama birinchi marta yuborildi.
  created,

  /// Mavjud shartnoma o'zgardi.
  updated,
}

/// Shartnomalar ro'yxati eskirganini bildiruvchi signal.
///
/// Nega `core/` da: shartnomani `contract_create` yozadi, ro'yxatni esa
/// `contracts` ko'rsatadi, oqim `customers` dan boshlanadi. Feature featureni
/// import qilmaydi (1.3), shuning uchun xabar shu kanaldan o'tadi.
///
/// Nega `PushNotifications` ga qo'shilmadi: u — tashqi transport (Firebase
/// xabarlari), bu esa ilovaning ichki hodisasi. Bittasi o'zgarganda ikkinchisi
/// o'zgarmasligi kerak (10-bo'lim, S).
final class ContractChanges {
  final StreamController<ContractChange> _changes = StreamController<ContractChange>.broadcast();

  /// Ro'yxatni ko'rsatayotgan ekran uni qayta o'qishi kerak.
  Stream<ContractChange> get changes => _changes.stream;

  void mark(ContractChange change) {
    if (_changes.isClosed) return;

    _changes.add(change);
  }

  Future<void> dispose() => _changes.close();
}
