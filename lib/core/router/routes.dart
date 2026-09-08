import 'package:colloborator_v3/core/router/coordinate.dart';

class Routes implements Coordinate {
  const Routes._({required this.name,required this.path});

  final String name;
  final String path;

  static const contracts = Routes._(
    name: 'contracts_page',
    path: '/contracts',
  );

  static const outputs = Routes._(
    name: 'outputs_page',
    path: '/outputs',
  );

  static const invoices = Routes._(
    name: 'invoices_page',
    path: '/invoices',
  );

  static const splash = Routes._(
    name: 'splash_page',
    path: '/splash',
  );

  static const login = Routes._(
    name: 'login_page',
    path: '/login',
  );

  static const registration = Routes._(
    name: 'registration_page',
    path: '/registration',
  );
 
  static const customer = Routes._(
    name: 'customer_page',
    path: '/customer',
    );

  static const products = Routes._(
    name: 'products_page',
    path: '/products',
    );

  static const anderrayter = Routes._(
    name: 'anderrayter_page',
    path: '/anderrayter',
  );

  static const outputsProducts = Routes._(
    name: 'outputs_products_page',
    path: '/outputs_products',
  );

  static const faceId = Routes._(
    name: 'face_id_page',
    path: '/face-id',
  );

  static const faceCamera = Routes._(
    name: 'face_camera_page',
    path: '/face-camera',
  );

  static const addCustomer = Routes._(
    name: 'add_customer_page',
    path: '/add_customer',
  );

  static const contractDetails = Routes._(
    name: 'contract_details_page',
    path: '/contract-details',
  );

  static const productPicker = Routes._(
    name: 'product_picker_page',
    path: '/product-picker',
  );

  static const addProduct = Routes._(
    name: 'add_product_page',
    path: '/add_product',
  );

  static const addContract = Routes._(
    name: 'add_contract_page',
    path: '/add_contract',
  );

  // Shartnoma tuzish ekrani va uning qo'shimcha ekranlari.
  static const guarantorPicker = Routes._(
    name: 'guarantor_picker_page',
    path: '/guarantor_picker',
  );

  static const paymentSchedule = Routes._(
    name: 'payment_schedule_page',
    path: '/payment_schedule',
  );

  static const specialTariff = Routes._(
    name: 'special_tariff_page',
    path: '/special_tariff',
  );

  static const managerBonus = Routes._(
    name: 'manager_bonus_page',
    path: '/manager_bonus',
  );

  static const katmSkip = Routes._(
    name: 'katm_skip_page',
    path: '/katm_skip',
  );

  static const contractConfirm = Routes._(
    name: 'contract_confirm_page',
    path: '/contract_confirm',
  );

  static const contractResult = Routes._(
    name: 'contract_result_page',
    path: '/contract_result',
  );

  static const autoPayment = Routes._(
    name: 'auto_payment_page',
    path: '/auto_payment',
  );

  static const update = Routes._(
    name: 'update_page',
    path: '/update',
  );

  static const customerAnalysis = Routes._(
    name: 'customer_analysis_page',
    path: '/customer_analysis',
  );

  static const changePassword = Routes._(
    name: 'change_password_page',
    path: '/change_password',
  );

  static const questionarie = Routes._(
    name: 'questionarie_page',
    path: '/questionarie',
  );

  static const requirementPage = Routes._(
    name: 'requirement_page',
    path: '/requirement_page',
  );

  static const iosCredentialPage = Routes._(
    name: 'ios_credential_page',
    path: '/ios_credential_page',
  );

  @override
  String toString() => 'name=$name, path=$path';
}
