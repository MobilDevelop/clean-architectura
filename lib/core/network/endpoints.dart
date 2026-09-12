abstract final class Endpoints {
 static const String _prefix = '/api/api/';

 // login_page all url
  static const String login = "${_prefix}sign-in";
  static const String logOut = "${_prefix}logout";

  // registration page all urls
  static const String partners = "${_prefix}get_partner_list_with_organizations";
  static const String rules = "${_prefix}get_partner_user_rules";
  static const String registration = "${_prefix}register_partner_user";

  // customer_page all url
  static const String getCustomer = "${_prefix}client-search";
  static const String checkClient = "${_prefix}check_client_by_myid";
  static const String provinces = "${_prefix}provinces";
  static const String regions = "${_prefix}regions";
  static const String villages = "${_prefix}get_mfy_by_region_id";
  static const String workplaces = "${_prefix}workplaces";
  static const String updateClient = "${_prefix}update_client_data";
  static const String scoringResult = "${_prefix}local-scoring-result/";

  // contracts page all ulrs
  static const String getContracts = "${_prefix}contracts";
  static const String contractScoring = "${_prefix}scoring-result/";
  static const String flexContracts = "${_prefix}flex-contracts/";
  static const String authorityCheck = "${_prefix}contract-authority/check/";
  static const String authorityConfirm = "${_prefix}contract-authority/confirm";
  static const String authorityEscalate = "${_prefix}contract-authority/escalate";
  static const String cancelContract = "${_prefix}loan_rejected/";
  /// Eski dvijokdagi "yuqoriga yuborish": `contracts/{id}/allow-confirmation`.
  static const String contractsBase = "${_prefix}contracts/";

  // contract_create feature — mahsulot tanlash.
  // Nomi `partners` emas: registratsiyadagi hamkorlar ro'yxati boshqa endpoint.
  static const String suppliers = "${_prefix}partners";
  static const String categories = "${_prefix}categories";
  static const String brands = "${_prefix}brands";
  static const String products = "${_prefix}products";
  static const String imeiImage = "${_prefix}imei/phone/img";

  // contract_create feature — qoralama va yuborish
  static const String loans = "${_prefix}loans";
  static const String loanDraft = "${_prefix}loans/draft";
  static const String loanById = "${_prefix}loans/";
  static const String paymentDays = "${_prefix}contract_payment_days/";
  static const String addLoanProduct = "${_prefix}add_loan_products";
  static const String updateLoanProduct = "${_prefix}update_loan_product/";
  static const String deleteLoanProduct = "${_prefix}delete_loan_product/";

  // contract_create feature — kafillar
  static const String addLoanGuarantor = "${_prefix}add_loan_guarantor";
  static const String deleteLoanGuarantor = "${_prefix}delete_loan_guarantor/";

  // contract_create feature — daromad bloki
  static const String occupationAutocomplete = "${_prefix}occupation-types/get-all-autocomplete";
  static const String occupationAll = "${_prefix}occupation-types/all";
  static const String addLoanCard = "${_prefix}add_loan_plastic_card";
  static const String deleteLoanCard = "${_prefix}delete_loan_plastic_card/";

  // contract_create feature — to'lov jadvali va maxsus tarif
  static const String generateGraphic = "${_prefix}generate_graphic";
  static const String specialTariffsAvailable = "${_prefix}special-tariffs/available";

  /// `contracts/{id}/special-tariff` — biriktirish, o'qish va bekor qilish.
  static String specialTariffOf(int contractId) => "$contractsBase$contractId/special-tariff";

  // contract_create feature — KATM skip va menejer bonusi
  static const String turnOffKatm = "${_prefix}underwriter/turn-off-katm";
  static const String skipReasonCategories = "${_prefix}underwriter/skip-reason-categories";
  static const String managerBonus = "${_prefix}contract/benefit";

  // underwriter feature — daromad hujjatlari
  static const String underwriters = "${_prefix}underwriters";
  static const String uploadS3Url = "${_prefix}upload-s3-url";
  static const String militaryPositions = "${_prefix}military-positions";
  static const String carBrands = "${_prefix}car-brands";
  static const String carModels = "${_prefix}car-models";

  // outputs feature — chiqim tovarlar
  static const String outputContracts = "${_prefix}output_contracts";
  static const String outputProducts = "${_prefix}get_products_for_cancelled/";
  static const String outputSmsConfirm = "${_prefix}contract/sms_confirm";
  static const String productReturned = "${_prefix}product_returned";
  static const String icloudRequirements = "${_prefix}icloud-contracts/requirements";
  static const String icloudContracts = "${_prefix}icloud-contracts";

  // imzolash
  static const String electronicContract = "${_prefix}electronic_contract";
  static const String electronicFlexContract = "${_prefix}electronic_flex_contract";
  static const String confirmClientFace = "${_prefix}confirm_client_face";
  static const String confirmGuarantorFace = "${_prefix}confirm_guarantor_face";
  // shartnomaga qo'shilgan kartani tasdiqlash (ELMA OTP)
  static const String smsForCardConfirmation = "${_prefix}get_sms_for_card_confirmation/";
  static const String giveSmsCodeToElma = "${_prefix}give_sms_code_to_elma";

  static const String signClientContract = "${_prefix}sign_client_contract";
  static const String signGuarantorContract = "${_prefix}sign_guarantor_contract";
}
