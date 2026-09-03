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
}