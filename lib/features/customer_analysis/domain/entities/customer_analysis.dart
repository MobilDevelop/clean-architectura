import 'package:colloborator_v3/core/utils/card_expiry.dart';
import 'package:colloborator_v3/core/utils/uz_phone.dart';
import 'package:equatable/equatable.dart';

/// Backend holatni satr bilan yuboradi.
enum AnalysisStatus {
  created,
  inProgress,
  cancelled,
  edited,
  confirmed,
  rejected,
  failed,
  waitSmsCode,
  resendSmsCode,
  unknown;

  static AnalysisStatus fromCode(String code) => switch (code) {
    'created' => AnalysisStatus.created,
    'inprogress' => AnalysisStatus.inProgress,
    'cancelled' => AnalysisStatus.cancelled,
    'edited' => AnalysisStatus.edited,
    'confirmed' => AnalysisStatus.confirmed,
    'reject' => AnalysisStatus.rejected,
    'failed' => AnalysisStatus.failed,
    'wait_sms_code' => AnalysisStatus.waitSmsCode,
    'resend_sms_code' => AnalysisStatus.resendSmsCode,
    _ => AnalysisStatus.unknown,
  };

  /// Karta SMS kodi kutilmoqda — qator bosilganda tasdiqlash oynasi ochiladi.
  bool get needsSmsCode => this == waitSmsCode || this == resendSmsCode;
}

/// Kengaytirilgan tahlilda tekshirilgan karta.
final class AnalysisCard extends Equatable {
  const AnalysisCard({required this.id, required this.number, required this.expiry});

  final int id;

  /// Faqat raqamlar.
  final String number;

  /// `MM/YY`. Oy yoki yil kelmasa bo'sh.
  final String expiry;

  /// `0` — karta bilan tekshirilmagan (oddiy tahlil). Serverdan bo'sh
  /// obyekt keladi, bu meʼyoriy holat.
  bool get isEmpty => id == 0;

  @override
  List<Object?> get props => <Object?>[id, number, expiry];
}

/// Bitta mijoz tahlili so'rovi va uning natijasi.
final class CustomerAnalysis extends Equatable {
  const CustomerAnalysis({
    required this.id,
    required this.fullName,
    required this.inps,
    required this.status,
    required this.createdAt,
    required this.elmaApplicationId,
    required this.elmaInstanceId,
    required this.freeLimit,
    required this.phone,
    required this.card,
  });

  /// SMS tasdiqlashda `pre_scoring_id` bo'lib ketadi.
  final int id;

  final String fullName;
  final String inps;
  final AnalysisStatus status;

  /// Server formatlangan satr yuboradi (shartnoma va faktura kartalari
  /// bilan bir xil qolip).
  final String createdAt;

  final String elmaApplicationId;
  final String elmaInstanceId;

  /// So'mda.
  final int freeLimit;

  /// Faqat raqamlar.
  final String phone;

  final AnalysisCard card;

  @override
  List<Object?> get props => <Object?>[
    id,
    fullName,
    inps,
    status,
    createdAt,
    elmaApplicationId,
    elmaInstanceId,
    freeLimit,
    phone,
    card,
  ];
}

/// Kengaytirilgan tahlilda kiritiladigan karta ma'lumoti.
///
/// Nega domainda: backend ham shu shaklni tekshiradi — `contracts` featuridagi
/// `CardEntry` bilan bir xil qoida (7.3).
final class AnalysisCardEntry extends Equatable {
  const AnalysisCardEntry({required this.phone, required this.number, required this.expiry});

  const AnalysisCardEntry.empty() : phone = '', number = '', expiry = '';

  /// Faqat raqamlar, `998...` bilan (`UzPhone.digits`).
  final String phone;

  /// Faqat raqamlar.
  final String number;

  /// `MM/YY`.
  final String expiry;

  static const int numberLength = 16;

  int get month => int.tryParse(expiry.length >= 2 ? expiry.substring(0, 2) : '') ?? 0;

  int get year => int.tryParse(expiry.length >= 5 ? expiry.substring(3, 5) : '') ?? 0;

  @override
  List<Object?> get props => <Object?>[phone, number, expiry];
}

/// Kiritishga to'sqinlik qilayotgan kamchilik.
enum AnalysisIssue {
  none,
  inpsIncomplete,
  contactPhoneInvalid,
  cardPhoneInvalid,
  cardNumberInvalid,
  cardExpiryInvalid,
}

/// Mijoz tahlili so'rovi.
final class AnalysisRequest extends Equatable {
  const AnalysisRequest({
    required this.inps,
    required this.contactPhone,
    required this.isAdvanced,
    required this.card,
  });

  /// Faqat raqamlar, `inpsDigits` xona.
  final String inps;

  /// Ixtiyoriy — bog'lanish uchun. Bo'sh yoki to'liq (`UzPhone.digits`).
  final String contactPhone;

  /// Karta orqali kengaytirilgan tahlil yoqilganmi.
  final bool isAdvanced;

  final AnalysisCardEntry card;

  static const int inpsDigits = 14;

  AnalysisIssue issueAt(DateTime now) {
    if (inps.length != inpsDigits) return AnalysisIssue.inpsIncomplete;
    if (contactPhone.isNotEmpty && !UzPhone.isValid(contactPhone)) {
      return AnalysisIssue.contactPhoneInvalid;
    }
    if (!isAdvanced) return AnalysisIssue.none;
    if (!UzPhone.isValid(card.phone)) return AnalysisIssue.cardPhoneInvalid;
    if (card.number.length != AnalysisCardEntry.numberLength) return AnalysisIssue.cardNumberInvalid;
    if (!CardExpiry.isUsable(month: card.month, year: card.year, now: now)) {
      return AnalysisIssue.cardExpiryInvalid;
    }

    return AnalysisIssue.none;
  }

  @override
  List<Object?> get props => <Object?>[inps, contactPhone, isAdvanced, card];
}

/// SMS kodni tasdiqlash so'rovi.
final class AnalysisSmsParams extends Equatable {
  const AnalysisSmsParams({
    required this.id,
    required this.elmaApplicationId,
    required this.elmaInstanceId,
    required this.code,
  });

  final int id;
  final String elmaApplicationId;
  final String elmaInstanceId;

  /// ELMA kodi harf ham bo'lishi mumkinligi aniqlanmagan — shuning uchun
  /// oddiy matn sifatida saqlanadi, raqamga cheklanmaydi.
  final String code;

  @override
  List<Object?> get props => <Object?>[id, elmaApplicationId, elmaInstanceId, code];
}
