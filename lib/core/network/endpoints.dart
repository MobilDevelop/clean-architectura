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

  // contracts page all ulrs
  static const String getContracts = "${_prefix}contracts";
}