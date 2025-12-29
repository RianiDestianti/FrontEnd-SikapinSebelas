import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'sp_ph_channel',
    'SP/PH Notifications',
    channelDescription: 'Notifikasi SP dan PH',
    importance: Importance.max,
    priority: Priority.high,
  );

  static const NotificationDetails _notificationDetails =
      NotificationDetails(android: _androidDetails);

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _notificationsPlugin.initialize(initSettings);

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showNotificationFromMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _notificationsPlugin.show(
      notification.hashCode,
      notification.title ?? 'Notifikasi',
      notification.body ?? '',
      _notificationDetails,
      payload: message.data['nis']?.toString(),
    );
  }
}
