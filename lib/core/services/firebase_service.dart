import 'dart:async';

import 'package:colloborator_v3/core/services/firebase_options.dart';
import 'package:colloborator_v3/core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vibration/vibration.dart';

/// Push xabarlarga obuna bo'ladi va ular kelganda bildirishnoma ko'rsatadi.
///
/// Nega singleton emas: obyekt DI da bir marta yaratiladi va shu yerda
/// saqlanadi. Klass ichida yashirin nusxa bo'lsa, testda uni almashtirib
/// bo'lmaydi — `FirebaseMessaging` ham shuning uchun konstruktordan kiradi (8.1).
final class FirebaseService {
  FirebaseService(this._messaging);

  final FirebaseMessaging _messaging;

  StreamSubscription<RemoteMessage>? _messages;

  Future<void> initialize() async {
    // Ruxsat ikkala platformada ham shu chaqiruv orqali so'raladi:
    // iOS'da tizim dialogi, Android 13+ da POST_NOTIFICATIONS.
    await _messaging.requestPermission();

    _messages = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await Vibration.vibrate(duration: 300);
      await LocalNotificationService.show(
        title: message.data['message'] as String? ?? '',
        subtitle: '',
      );
    });
  }

  Future<void> dispose() async {
    await _messages?.cancel();
    _messages = null;
  }
}

/// Ilova fonda yoki yopiq bo'lganda kelgan xabar.
///
/// Nega alohida yuqori darajadagi funksiya: Firebase uni alohida izolyatda
/// chaqiradi, shuning uchun u klass a'zosi bo'la olmaydi va DI ni ko'rmaydi.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Tizim o'zi ko'rsatadigan bildirishnoma bo'lsa, ikkinchisini chizmaymiz.
  if (message.notification != null) return;

  await LocalNotificationService.instance.init();
  await LocalNotificationService.show(
    title: message.data['message'] as String? ?? '',
    subtitle: '',
  );
}
