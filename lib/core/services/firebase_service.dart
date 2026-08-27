import 'dart:async';

import 'package:colloborator_v3/core/services/firebase_options.dart';
import 'package:colloborator_v3/core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vibration/vibration.dart';


class FirebaseService {
  static final FirebaseService _instance = FirebaseService._();

  factory FirebaseService() => _instance;

  FirebaseService._();

  late StreamSubscription<RemoteMessage> _fsmMessagesub;
  late StreamSubscription<RemoteMessage> _openedAppSubscription;

  Future<void> initialize() async {
    // Ruxsat ikkala platformada ham shu chaqiruv orqali so'raladi:
    // iOS'da tizim dialogi, Android 13+ da POST_NOTIFICATIONS.
    await FirebaseMessaging.instance.requestPermission();

    _fsmMessagesub = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await Vibration.vibrate(duration: 300);
      await LocalNotificationService.show(title: message.data['message'] as String? ?? '', subtitle: '');
    });

    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Tap qilinganda app ochilishi tizim tomonidan boshqariladi.
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {}
  }

  void dispose() {
    _fsmMessagesub.cancel();
    _openedAppSubscription.cancel();
  }
}

 @pragma('vm:entry-point')
  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    if (message.notification != null) return;
    await LocalNotificationService.instance.init(); 
    await LocalNotificationService.show(title: message.data['message'] as String? ?? '', subtitle: '');
  }
