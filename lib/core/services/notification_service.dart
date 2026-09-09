import 'package:colloborator_v3/core/services/push_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Tizim bildirishnomasini chizadi va bosilganini `PushNotifications` ga
/// uzatadi.
///
/// Nega `static` emas: obyekt DI da yaratiladi va bog'liqliklari
/// konstruktordan kiradi (8.1). Ilgari u `instance` singletoni edi va
/// `FirebaseService` uni statik chaqirardi — testda almashtirib bo'lmasdi.
final class LocalNotificationService {
  const LocalNotificationService({required this.plugin, required this._push});

  final FlutterLocalNotificationsPlugin plugin;
  final PushNotifications _push;

  static const AndroidNotificationDetails _android = AndroidNotificationDetails(
    'default_channel',
    'Default Notifications',
    channelDescription: 'Default Notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    icon: '@mipmap/ic_launcher',
  );

  static const DarwinNotificationDetails _ios = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  Future<void> init() async {
    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await plugin.initialize(
      settings: settings,
      // Ilgari bu yerda payloadga qaramasdan Android "Yuklanmalar" papkasi
      // ochilardi — shartnoma bildirishnomasi bosilganda ham. Endi payload
      // xabarning o'zini olib keladi.
      onDidReceiveNotificationResponse: (NotificationResponse response) =>
          _push.open(PushMessage.fromPayload(response.payload)),
    );

    // Ilova aynan shu bildirishnoma bosilgani uchun ochilgan bo'lishi mumkin:
    // u holda `onDidReceiveNotificationResponse` chaqirilmaydi.
    final NotificationAppLaunchDetails? launch = await plugin.getNotificationAppLaunchDetails();
    final NotificationResponse? response = launch?.notificationResponse;

    if ((launch?.didNotificationLaunchApp ?? false) && response != null) {
      _push.open(PushMessage.fromPayload(response.payload));
    }

    await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Bildirishnoma chizadi. `id` o'zgarmas: yangi xabar eskisining o'rnini
  /// egallaydi, ya'ni panelda o'nlab takror to'planmaydi.
  Future<void> show(PushMessage message) => plugin.show(
    id: 77,
    title: message.text,
    body: '',
    notificationDetails: const NotificationDetails(android: _android, iOS: _ios),
    payload: message.payload,
  );
}

/// Fon izolyati uchun bildirishnoma. DI ko'rinmaydi, shuning uchun plagin
/// nusxasi shu yerda yaratiladi.
Future<void> showBackgroundNotification(PushMessage message) async {
  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  await plugin.show(
    id: 77,
    title: message.text,
    body: '',
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'default_channel',
        'Default Notifications',
        channelDescription: 'Default Notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: message.payload,
  );
}
