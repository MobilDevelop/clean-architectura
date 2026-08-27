import 'package:hive_flutter/adapters.dart';

class LocalSource {
  static final box = Hive.box<String>("Mymemory");

  static Future<void> putInfo({required String key, required String json}) async => await box.put(key, json);
  static String getInfo({required String key}) =>  box.get(key) ?? '';


  /// userInfo getter and setter
  // static set saveUserJson(Map<String,dynamic> userMap) => box.put("userInfoModel", jsonEncode(userMap));
  // static UserModel get getUserJson => UserModel.fromJson(jsonDecode(box.get("userInfoModel")??"{}"), userToken);

  /// Clear Profile
  static Future<void> clearProfile() async => await box.clear();
}
