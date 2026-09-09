import 'dart:async';

import 'package:colloborator_v3/core/services/firebase_options.dart';
import 'package:colloborator_v3/core/services/notification_service.dart';
import 'package:colloborator_v3/core/services/push_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vibration/vibration.dart';

/// Push xabarlarga obuna bo'ladi: bildirishnoma ko'rsatadi va xabarni
/// `PushNotifications` kanaliga uzatadi.
///
/// Nega singleton emas: obyekt DI da bir marta yaratiladi. Klass ichida
/// yashirin nusxa bo'lsa, testda uni almashtirib bo'lmaydi (8.1).
final class FirebaseService {
  FirebaseService(this._messaging, this._push, this._notifications);

  final FirebaseMessaging _messaging;
  final PushNotifications _push;
  final LocalNotificationService _notifications;

  StreamSubscription<RemoteMessage>? _messages;
  StreamSubscription<RemoteMessage>? _opened;

  Future<void> initialize() async {
    // Ruxsat ikkala platformada ham shu chaqiruv orqali so'raladi:
    // iOS'da tizim dialogi, Android 13+ da POST_NOTIFICATIONS.
    await _messaging.requestPermission();

    // Ilova ochiq turibdi: tizim o'zi hech nima ko'rsatmaydi.
    _messages = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final PushMessage push = PushMessage.fromData(message.data);

      _push.receive(push);

      await Vibration.vibrate(duration: 300);
      await _notifications.show(push);
    });

    // Ilova fonda edi va tizim bildirishnomasi bosildi.
    _opened = FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) => _push.open(PushMessage.fromData(message.data)),
    );

    // Ilova umuman yopiq edi: uni aynan shu bildirishnoma ishga tushirgan.
    final RemoteMessage? initial = await _messaging.getInitialMessage();
    if (initial != null) _push.open(PushMessage.fromData(initial.data));
  }

  Future<void> dispose() async {
    await _messages?.cancel();
    await _opened?.cancel();
    _messages = null;
    _opened = null;
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

  await showBackgroundNotification(PushMessage.fromData(message.data));
}
