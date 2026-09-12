import 'package:equatable/equatable.dart';

/// Chiqimdan oldingi iCloud talablari.
///
/// Apple qurilmasi chiqim qilinishidan oldin uning iCloud ma'lumotlari
/// yozilgan bo'lishi kerak. Talab bajarilmagan bo'lsa chiqim ochilmaydi.
final class IcloudRequirements extends Equatable {
  const IcloudRequirements({
    required this.contractId,
    required this.isSatisfied,
    required this.devices,
  });

  final int contractId;

  /// Hamma qurilma to'ldirilgan — chiqim berish mumkin.
  final bool isSatisfied;

  /// To'ldirilishi kerak bo'lgan qurilmalar.
  final List<IcloudDevice> devices;

  @override
  List<Object?> get props => <Object?>[contractId, isSatisfied, devices];
}

/// Talab qo'yilgan bitta qurilma.
final class IcloudDevice extends Equatable {
  const IcloudDevice({
    required this.contractProductId,
    required this.productId,
    required this.name,
    required this.fullName,
    required this.imei,
    required this.imei2,
    required this.missing,
  });

  /// Shartnoma qatorining id si — yozuv shunga bog'lanadi.
  final int contractProductId;

  final int productId;
  final String name;
  final String fullName;

  /// Serverda bor bo'lsa forma uni o'zgartirtirmaydi: raqam yorliqdan
  /// o'qilgan va uni qo'lda qayta yozish xato kiritishning yo'li.
  final String imei;
  final String imei2;

  /// Yana nechta yozuv yetishmayapti. `null` — server bermadi.
  ///
  /// Nega zaxira qiymat yo'q (4.6): `0` «to'ldirilgan» degani, ya'ni kalit
  /// kelmaganda `0` qo'yish barcha qurilmani jimgina o'chirib qo'yardi.
  final int? missing;

  /// To'ldirilgan qurilma qayta ochilmaydi.
  bool get isFilled => missing == 0;

  @override
  List<Object?> get props => <Object?>[contractProductId, productId, name, fullName, imei, imei2, missing];
}

/// Apple ID ning kimga tegishliligi.
///
/// Serverga matn bo'lib ketadi, lekin qaysi matn ekani — data qatlamining
/// ishi (3.1): domain backend yozuvini saqlamaydi.
enum AppleIdOwner { own, personal }

/// iCloud formasida nima yetishmayapti.
enum IcloudIssue {
  none,
  conditionMissing,
  boxMissing,
  imeiShort,
  serialMissing,
  loginMissing,
  passwordMissing,
  appleLoginMissing,
  applePasswordMissing,
  restrictionShort,
  phoneShort,
}

/// iCloud ma'lumotlari formasi.
///
/// Ham qoralama, ham usecase kirishi (3.3): to'ldirilishi va yuborilishi bir
/// xil maydonlar to'plami, ikkinchi nusxasi faqat nomlarni ikki joyda
/// saqlashga olib kelardi.
final class IcloudCredential extends Equatable {
  const IcloudCredential({
    required this.contractId,
    required this.contractProductId,
    this.condition = '',
    this.hasBox,
    this.imei = '',
    this.imei2 = '',
    this.serialNumber = '',
    this.login = '',
    this.password = '',
    this.appleLogin,
    this.applePassword,
    this.restrictionCode = '',
    this.phone = '',
  });

  final int contractId;
  final int contractProductId;

  /// Qurilmaning holati (yangi, ishlatilgan) — erkin matn.
  final String condition;

  /// `null` — hali tanlanmagan.
  final bool? hasBox;

  final String imei;

  /// Ikkinchi IMEI ixtiyoriy: bitta SIM'li qurilmada u umuman bo'lmaydi.
  final String imei2;

  final String serialNumber;
  final String login;
  final String password;
  final AppleIdOwner? appleLogin;
  final AppleIdOwner? applePassword;

  /// Qurilmadagi cheklov (Screen Time) kodi — to'rt raqam.
  final String restrictionCode;

  /// iCloud'ga bog'langan raqam, faqat raqamlar (`998901234567`).
  final String phone;

  static const int imeiLength = 15;
  static const int restrictionLength = 4;

  /// `998` + to'qqiz raqam. Ilovaning qolgan qismi ham raqamni shu shaklda
  /// yuboradi; flex bu maydonda maskani o'zini (`(90) 123-45-67`) yuborardi.
  static const int phoneLength = 12;

  IcloudIssue get issue {
    if (condition.trim().isEmpty) return IcloudIssue.conditionMissing;
    if (hasBox == null) return IcloudIssue.boxMissing;
    if (imei.trim().length < imeiLength) return IcloudIssue.imeiShort;
    if (serialNumber.trim().isEmpty) return IcloudIssue.serialMissing;
    if (login.trim().isEmpty) return IcloudIssue.loginMissing;
    if (password.trim().isEmpty) return IcloudIssue.passwordMissing;
    if (appleLogin == null) return IcloudIssue.appleLoginMissing;
    if (applePassword == null) return IcloudIssue.applePasswordMissing;
    if (restrictionCode.trim().length < restrictionLength) return IcloudIssue.restrictionShort;
    if (phone.length < phoneLength) return IcloudIssue.phoneShort;

    return IcloudIssue.none;
  }

  IcloudCredential copyWith({
    String? condition,
    bool? hasBox,
    String? imei,
    String? imei2,
    String? serialNumber,
    String? login,
    String? password,
    AppleIdOwner? appleLogin,
    AppleIdOwner? applePassword,
    String? restrictionCode,
    String? phone,
  }) => IcloudCredential(
    contractId: contractId,
    contractProductId: contractProductId,
    condition: condition ?? this.condition,
    hasBox: hasBox ?? this.hasBox,
    imei: imei ?? this.imei,
    imei2: imei2 ?? this.imei2,
    serialNumber: serialNumber ?? this.serialNumber,
    login: login ?? this.login,
    password: password ?? this.password,
    appleLogin: appleLogin ?? this.appleLogin,
    applePassword: applePassword ?? this.applePassword,
    restrictionCode: restrictionCode ?? this.restrictionCode,
    phone: phone ?? this.phone,
  );

  @override
  List<Object?> get props => <Object?>[
    contractId,
    contractProductId,
    condition,
    hasBox,
    imei,
    imei2,
    serialNumber,
    login,
    password,
    appleLogin,
    applePassword,
    restrictionCode,
    phone,
  ];
}
