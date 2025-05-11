import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_service.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Инициализация сервиса push-уведомлений
  Future<void> initialize() async {
    // Запрос разрешения на получение уведомлений
    await _fcm.requestPermission();

    // Получение токена
    final token = await _fcm.getToken();
    print("FCM Token: $token");

    // Отправка токена на сервер
    if (token != null) {
      await ApiService.sendFcmToken(token);
    }

    // Обработка обновления токена
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await ApiService.sendFcmToken(newToken);
    });

    // Настройка локальных уведомлений
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          0,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_id',
              'Main Channel',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Обработка фоновых сообщений
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint("Handling background message: ${message.messageId}");
  }

  /// Удаление FCM токена
  Future<void> deleteFcmToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
      debugPrint("FCM токен удалён с устройства");
    } catch (e) {
      debugPrint("Ошибка при удалении FCM токена: $e");
    }
  }
}
