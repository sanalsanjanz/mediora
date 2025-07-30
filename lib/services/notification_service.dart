import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mediora/firebase_options.dart';
import 'package:mediora/patients/views/booking_checkpoint.dart';

class NotificationService {
  static final _fln = FlutterLocalNotificationsPlugin();
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await _firebaseMessaging.requestPermission();

    FirebaseMessaging.onBackgroundMessage(_firebaseBgHandler);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final bookingId = message.data['bookingId'];
      if (bookingId != null) _openBooking(bookingId);
    });

    // Local notification settings
    const androidChannel = AndroidNotificationChannel(
      'booking',
      'Booking updates',
      description: 'Status + reminders',
      importance: Importance.high,
    );

    await _fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_ic_notification'),
      iOS: DarwinInitializationSettings(),
    );

    await _fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        _openBooking(resp.payload);
      },
    );
  }

  static Future<String?> getFcmToken() async {
    return await _firebaseMessaging.getToken();
  }

  static void _onForegroundMessage(RemoteMessage message) {
    if (message.notification == null && message.data.isEmpty) return;
    _showLocal(message);
  }

  static Future<void> _firebaseBgHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    _showLocal(message);
  }

  static void _showLocal(RemoteMessage message) {
    final data = message.data;
    final title = message.notification?.title ?? data['title'];
    final body = message.notification?.body ?? data['body'];

    if (title == null || body == null) return;

    _fln.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'booking',
          'Booking updates',
          icon:
              'ic_stat_ic_notification', // ✅ required for background notifications
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: data['bookingId'],
    );
  }

  static void _openBooking(String? bookingId) async {
    final fcmToken = await NotificationService.getFcmToken();
    if (bookingId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) =>
              BookingCheckpoint(bookingId: bookingId, tocken: fcmToken ?? ""),
        ),
      );
    }
  }
}
