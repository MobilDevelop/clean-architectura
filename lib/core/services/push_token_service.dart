import 'package:firebase_messaging/firebase_messaging.dart';

final class PushTokenService {
  const PushTokenService(this._messaging);

  final FirebaseMessaging _messaging;

  Future<String> get() async {
    try {
      return await _messaging.getToken() ?? '';
    } catch (_) {
      return '';
    }
  }
}