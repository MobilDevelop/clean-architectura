/// KATM javobida summa bo'lgan maydonlar.
///
/// Nega ro'yxat kerak: jadval qatorlaridagi qolgan maydonlar — kodlar
/// (`"000"`, `"01180"`, `"012.01"`) va songa aylantirilsa ma'nosi buziladi.
/// Shuning uchun faqat shu ro'yxatdagilar summa sifatida formatlanadi.
///
/// **Bo'lish yo'q.** KATM javobidagi summalar allaqachon so'mda keladi
/// (DEV-4085, `money.unit`). Tiyin faqat MIB javobida uchraydi va u yerda kasr
/// qismi bo'lib keladi (`432602.1`), ya'ni u ham bo'linmaydi.
abstract final class KatmMoneyFields {
  static const Set<String> keys = <String>{
    'amount',
    'amount_issued',
    'summa',
    'security_amount',
    'unused_limit',
    'total_debt_sum',
    'overdue_debt_sum',
    'overdue_principal_sum',
    'overdue_percent_sum',
    'immediate_principal_sum',
    'immediate_percent_sum',
    'monthly_average_payment',
    'average_monthly_payment',
    'max_overdue_principal_sum',
    'total_overdue_percent_sum',
    'actual_average_monthly_payment',
    'begin_sum',
    'end_sum',
    'principal_sum',
    'percent_sum',
    'remaining_principal_sum',
    'reserve_bal_sum',
    'discount_sum',
    'revised_principal_sum',
    'lawsuit_principal_sum',
    'closed_lawsuit_principal_sum',
    'offbalance_princial_sum',
    'offbalance_percent_sum',
    'remaining_limit_sum',
    'closed_offbalance_princial_sum',
    'closed_offbalance_percent_sum',
  };

  static bool isMoney(String key) => keys.contains(key);
}
