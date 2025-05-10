import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Запрос разрешения на получение уведомлений
    await _fcm.requestPermission();

    // Получение токена
    final token = await _fcm.getToken();
    print("FCM Token: $token");

    // TODO Отправить токен на сервер
    // await ApiService.sendFcmToken(token!);

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

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Handling background message: ${message.messageId}");
  }
}
