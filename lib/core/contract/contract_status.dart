/// Shartnomaning serverdagi holati.
///
/// Kod → holat aylantirilishi shu yerda: uni ikkita feature ishlatadi
/// (shartnomalar ro'yxati va shartnoma tuzish), shuning uchun DTO ichida
/// yashirinib qololmaydi (1.2).
enum ContractStatus {
  created,
  scoring,
  failed,
  notAllowed,
  rejected,
  edited,
  allowed,
  faceVerified,
  signed,
  confirmed,
  canceledByClient,
  invoiceCreated,
  canceled,
  waitingSms,
  errorFound,
  invoiceConfirmed,
  incomeSelect,
  unknown;

  static ContractStatus fromCode(int code) => switch (code) {
    1 => ContractStatus.created,
    2 || 3 => ContractStatus.scoring,
    4 => ContractStatus.failed,
    5 || 23 => ContractStatus.notAllowed,
    6 => ContractStatus.rejected,
    7 => ContractStatus.edited,
    8 => ContractStatus.allowed,
    9 => ContractStatus.faceVerified,
    10 => ContractStatus.signed,
    11 => ContractStatus.confirmed,
    12 => ContractStatus.canceledByClient,
    15 => ContractStatus.invoiceCreated,
    16 => ContractStatus.canceled,
    24 => ContractStatus.waitingSms,
    25 => ContractStatus.errorFound,
    27 => ContractStatus.invoiceConfirmed,
    40 => ContractStatus.incomeSelect,
    _ => ContractStatus.unknown,
  };
}
