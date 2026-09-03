/// KATM hujjatidagi maydonlar qanday nom bilan chizilishi.
///
/// Bo'limlar tartibi backenddan (`layout`) keladi, lekin u ustunlarni bermaydi:
/// bitta `contracts` yozuvida 71 tagacha maydon bor. Shuning uchun ko'rsatiladigan
/// maydonlar shu yerda belgilanadi.
abstract final class KatmLabels {
  /// Umumiy ko'rsatkichlar bo'limi.
  static const Map<String, String> overview = <String, String>{
    'contracts_qty': 'Shartnomalar soni',
    'claims_qty': 'Arizalar soni',
    'credit_request_qty': "Kredit so'rovlari soni",
    'subscriptions_qty': 'Obunalar soni',
    'contingent_liabilities_qty': 'Shartli majburiyatlar soni',
    'overdue_principal_qty': 'Kechikishlar soni',
    'max_overdue_principal_days': 'Eng uzun kechikish (kun)',
    'max_uninter_overdue_percent_days': 'Eng uzun uzluksiz foiz kechikishi (kun)',
    'max_overdue_principal_sum': 'Eng katta kechiktirilgan asosiy qarz',
    'total_overdue_percent_sum': 'Kechiktirilgan foizlar jami',
    'average_monthly_payment': "O'rtacha oylik to'lov",
    'actual_average_monthly_payment': "Amaldagi o'rtacha oylik to'lov",
  };

  /// Kredit axboroti subyekti.
  /// Viloyat va tuman chizilmaydi: KATM ularni faqat kod bilan yuboradi.
  static const Map<String, String> subject = <String, String>{
    'fio': 'F.I.Sh.',
    'client_type': 'Mijoz turi',
    'pinfl': 'JSHSHIR',
    'inn': 'INN',
    'birth_date': "Tug'ilgan sana",
    'gender': 'Jinsi',
    'juridical_status': 'Huquqiy maqomi',
  };

  /// Hujjat rekvizitlari — KATM sarlavhasi ostida.
  static const Map<String, String> meta = <String, String>{
    'report_name': 'Hisobot',
    'claim_id': 'Ariza №',
    'claim_date': 'Sanasi',
    'org_name': 'Tashkilot',
    'subject_type': 'Subyekt turi',
  };

  /// Kartochka sarlavhasi uchun eng muhim maydon.
  static const Map<String, String> primary = <String, String>{
    'contracts': 'org_name',
    'open_contracts': 'org_name',
    'contingent_liabilities': 'org_name',
    'claims_wo_contracts': 'org_name',
    'credit_requests': 'org_name',
    'subscriptions': 'org_name',
  };

  static const Map<String, Map<String, String>> columns = <String, Map<String, String>>{
    'open_contracts': <String, String>{
      'contract_id': 'Shartnoma',
      'currency_name': 'Valyuta',
      'total_debt_sum': 'Umumiy qarz',
      'overdue_debt_sum': "Muddati o'tgan",
      'monthly_average_payment': "O'rtacha oylik",
    },
    'contracts': <String, String>{
      'contract_id': 'Shartnoma',
      'contract_date': 'Boshlanish',
      'contract_end_date': 'Tugash',
      'contract_status_name': 'Holati',
      'credit_type_name': 'Kredit turi',
      'amount': 'Summa',
      'percent': 'Foiz',
      'total_debt_sum': 'Umumiy qarz',
      'overdue_principal_sum': "Muddati o'tgan asosiy qarz",
      'immediate_principal_sum': 'Joriy asosiy qarz',
    },
    'contingent_liabilities': <String, String>{
      'fio': 'F.I.Sh.',
      'contract_id': 'Shartnoma',
      'contract_date': 'Boshlanish',
      'contract_end_date': 'Tugash',
      'amount': 'Summa',
      'percent': 'Foiz',
      'total_debt_sum': 'Umumiy qarz',
      'overdue_debt_sum': "Muddati o'tgan",
    },
    'claims_wo_contracts': <String, String>{
      'claim_id': 'Ariza №',
      'claim_date': 'Sanasi',
      'rejection_date': 'Rad sanasi',
      'rejection_reason': 'Rad sababi',
      'summa': 'Qarz miqdori',
      'percent': 'Foiz',
      'credit_duration': 'Muddat',
    },
    'credit_requests': <String, String>{
      'claim_id': 'Ariza №',
      'report_type': 'Hisobot turi',
      'demand_date_time': "So'rov vaqti",
      'consent_id': 'Rozilik №',
      'consent_date': 'Rozilik sanasi',
    },
    'subscriptions': <String, String>{
      'claim_id': 'Ariza №',
      'consent_id': 'Rozilik №',
      'consent_date': 'Rozilik sanasi',
      'subscription_period': 'Obuna muddati',
    },
  };

  /// Shartnoma tafsilotida qo'shimcha ko'rsatiladigan maydonlar — jadval
  /// kartochkasiga sig'maganlari. Tartib KATM hujjatining 7-bo'limidagidek.
  static const Map<String, String> contractDetail = <String, String>{
    'org_type': 'Kreditor turi',
    'claim_id': 'Ariza №',
    'currency_name': 'Valyuta',
    'amount_issued': 'Berilgan summa',
    'contract_closing_date': 'Yopilgan sana',
    'overdue_percent_sum': "Muddati o'tgan foiz",
    'immediate_percent_sum': 'Joriy foiz',
    'class_asset_quality_name': 'Aktiv sifati',
    'unused_limit': 'Foydalanilmagan limit',
    'remaining_limit_sum': 'Qolgan limit',
    'security_qty': "Ta'minot soni",
    'reserve_bal_sum': "Zaxira qoldig'i",
    'discount_sum': 'Chegirma',
    'revised_principal_sum': "Qayta ko'rib chiqilgan asosiy qarz",
    'lawsuit_principal_sum': 'Sud jarayonidagi asosiy qarz',
    'closed_lawsuit_principal_sum': 'Yopilgan sud qarzi',
    'offbalance_princial_sum': 'Balansdan tashqari asosiy qarz',
    'offbalance_percent_sum': 'Balansdan tashqari foiz',
    'closed_offbalance_princial_sum': 'Yopilgan balansdan tashqari asosiy qarz',
    'closed_offbalance_percent_sum': 'Yopilgan balansdan tashqari foiz',
  };

  /// Muammoli summalar: sog'lom shartnomada hammasi nol bo'ladi, shuning uchun
  /// nol bo'lsa qator umuman chizilmaydi — aks holda har kartada 10 ta bo'sh
  /// qator turadi.
  static const Set<String> hideWhenZero = <String>{
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

  /// Shartnoma ichidagi ro'yxatlar. Faqat tafsilot ochilganda chiziladi.
  static const Map<String, String> nestedTitles = <String, String>{
    'balances': 'Oylik qoldiqlar',
    'forecasted_schedule': "Rejadagi to'lovlar",
    'actual_schedule': "Amaldagi to'lovlar",
    'overdue_principals': 'Asosiy qarz kechikishlari',
    'overdue_procents': 'Foiz kechikishlari',
    'securities': "Ta'minotlar",
  };

  static const Map<String, Map<String, String>> nestedColumns = <String, Map<String, String>>{
    'balances': <String, String>{'begin_sum': 'Boshlanish', 'end_sum': 'Yakun'},
    'forecasted_schedule': <String, String>{'principal_sum': 'Asosiy qarz', 'percent_sum': 'Foiz'},
    'actual_schedule': <String, String>{
      'principal_sum': 'Asosiy qarz',
      'percent_sum': 'Foiz',
      'remaining_principal_sum': 'Qoldiq',
    },
    'overdue_principals': <String, String>{'overdue_principal_sum': 'Summa', 'overdue_principal_days': 'Kun'},
    'overdue_procents': <String, String>{'overdue_principal_sum': 'Summa', 'overdue_principal_days': 'Kun'},
    'securities': <String, String>{
      'security_type': 'Turi',
      'amount': 'Summa',
      'name': 'Nomi',
      'pinfl': 'JSHSHIR',
      'inn': 'INN',
    },
  };

  /// Ichki ro'yxat qatorining sarlavhasi — davr yoki sana.
  static const Map<String, String> nestedPrimary = <String, String>{
    'balances': 'month',
    'forecasted_schedule': 'forecasted_payment_period',
    'actual_schedule': 'repayment_date',
    'overdue_principals': 'overdue_date',
    'overdue_procents': 'overdue_date',
    'securities': 'contract_date',
  };

  /// `open_contracts` dagi "Jami" qatori.
  static const Map<String, String> totals = <String, String>{
    'total_debt_sum': 'Umumiy qarz',
    'overdue_debt_sum': "Muddati o'tgan",
    'average_monthly_payment': "O'rtacha oylik",
  };

  /// KATM nomlarni ruschada yuboradi.
  ///
  /// Ro'yxatda uchragan qiymatlar bor; yangisi chiqsa xom holicha ko'rinadi —
  /// ya'ni ekran bo'sh qolmaydi.
  static const Map<String, String> values = <String, String>{
    'Открыт': 'Ochiq',
    'Закрыт': 'Yopiq',
    'Физическое лицо': 'Jismoniy shaxs',
    'Микрозаем': 'Mikroqarz',
    'Стандартный': 'Standart',
    'Субстандартный': 'Substandart',
    'БАНК': 'Bank',
    'МКО': 'MMT',
    'РЕТ': 'Savdo tashkiloti',
    'Узбекский сум (860)': 'UZS',
    'ОТЛИЧНЫЙ': "A'lo",
    'ХОРОШИЙ': 'Yaxshi',
    'СРЕДНИЙ': "O'rtacha",
    'НИЗКИЙ': 'Past',
    'ПЛОХОЙ': 'Yomon',

    // KATM "ma'lumot yo'q" o'rniga shu qisqartmani yuboradi.
    'н/д': '',
    'M': 'Erkak',
    'F': 'Ayol',
  };

  static String translate(String value) => values[value] ?? value;
}
