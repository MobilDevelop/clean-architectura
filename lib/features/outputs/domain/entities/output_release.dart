import 'dart:io';

import 'package:equatable/equatable.dart';

/// Chiqim tasdig'ida nima yetishmayapti.
enum ReleaseIssue { none, photoMissing, codeIncomplete }

/// Chiqim tasdig'i formasi: tovarlar surati va SMS kod.
///
/// Nega qoralama alohida: surat kamerada, kod klaviaturada to'ldiriladi va
/// ikkalasi ham bo'lmaguncha so'rov yuborilmaydi. Flex bu tekshiruvni bloc
/// ichida ikkita `if` bilan qilib, natijani toast qilib otardi — xato
/// maydonning yonida emas, ekranning tepasida chiqardi (7.5).
final class ReleaseDraft extends Equatable {
  const ReleaseDraft({this.photo, this.code = ''});

  /// Mijoz va tovar bir kadrda. Serverga `products_picture` bo'lib ketadi.
  final File? photo;

  final String code;

  /// SMS kod uzunligi. Server shuncha belgi yuboradi.
  static const int codeLength = 5;

  ReleaseIssue get issue {
    if (photo == null) return ReleaseIssue.photoMissing;
    if (code.trim().length < codeLength) return ReleaseIssue.codeIncomplete;

    return ReleaseIssue.none;
  }

  /// `photo` uchun `clearPhoto` yo'q: surat olingandan keyin u faqat boshqa
  /// suratga almashadi, tozalanmaydi.
  ReleaseDraft copyWith({File? photo, String? code}) =>
      ReleaseDraft(photo: photo ?? this.photo, code: code ?? this.code);

  @override
  List<Object?> get props => <Object?>[photo?.path, code];
}

/// Chiqim tasdig'i so'rovi.
final class ReleaseParams extends Equatable {
  const ReleaseParams({
    required this.contractId,
    required this.clientId,
    required this.code,
    required this.photo,
  });

  final int contractId;
  final int clientId;
  final String code;
  final File photo;

  @override
  List<Object?> get props => <Object?>[contractId, clientId, code, photo.path];
}

/// Tovar qaytarish so'rovi.
final class ProductReturnParams extends Equatable {
  const ProductReturnParams({required this.contractId, required this.productIds});

  final int contractId;

  /// Qaytariladigan tovar qatorlari. Bo'sh ro'yxat bilan so'rov yuborilmaydi.
  final List<int> productIds;

  @override
  List<Object?> get props => <Object?>[contractId, productIds];
}
