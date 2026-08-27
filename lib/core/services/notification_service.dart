import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class LocalNotificationService {
  static final LocalNotificationService instance = LocalNotificationService._();
  LocalNotificationService._();

  final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
     );

    await localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await openDownloadsFolder();
      },
    );

    // Android permission
    final androidPlugin = localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    // iOS permission
    final iosPlugin = localNotifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Yuklab olingan fayllar papkasini ochadi.
  ///
  /// Faqat Android: quyidagi URI'lar Android fayl tizimiga tegishli.
  /// iOS uchun alohida yo'l kerak — yuklab olish funksiyasi ko'chirilganda qo'shiladi.
  static Future<void> openDownloadsFolder() async {
    if (!Platform.isAndroid) return;

    try {
      final uri = Uri.parse(
          'content://com.android.externalstorage.documents/document/primary:Download');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      try {
        final uri = Uri.parse('file:///storage/emulated/0/Download');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Failed to open downloads folder: $e');
      }
    }
  }

  static Future<void> show({
    required String title,
    required String subtitle,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      channelDescription: 'Default Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await instance.localNotifications.show(
      id: 77,
      title: title,
      body: subtitle,
      notificationDetails: notificationDetails,
      payload: 'open_downloads',
    );
  }
}