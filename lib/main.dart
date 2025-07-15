import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mediora/firebase_options.dart';
import 'package:mediora/patients/views/patient_home_screen.dart';
import 'package:mediora/splash_screen.dart';

@pragma('vm:entry-point') // ← required
Future<void> _firebaseBgHandler(RemoteMessage m) async {
  await Firebase.initializeApp();
  _showLocal(m); // show tray notification
}

final _fln = FlutterLocalNotificationsPlugin(); // one global instance

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // iOS permission
  await FirebaseMessaging.instance.requestPermission();

  // Android channel (once)
  const channel = AndroidNotificationChannel(
    'booking',
    'Booking updates',
    description: 'Status + reminders',
    importance: Importance.high,
  );
  await _fln
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  const init = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await _fln.initialize(
    init,
    onDidReceiveNotificationResponse: (resp) => _openBooking(resp.payload),
  );

  // background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseBgHandler);

  // foreground handler
  FirebaseMessaging.onMessage.listen(_showLocal);

  // tap when app was killed
  FirebaseMessaging.onMessageOpenedApp.listen(
    (m) => _openBooking(m.data['bookingId']),
  );

  final token = await FirebaseMessaging.instance.getToken();
  print('FCM token: $token'); // send to backend

  runApp(MyApp(fcm: token ?? ''));
}

void _showLocal(RemoteMessage m) {
  final n = m.notification;
  if (n == null) return; // data‑only payloads

  _fln.show(
    m.hashCode,
    n.title,
    n.body,
    const NotificationDetails(
      android: AndroidNotificationDetails('booking', 'Booking updates'),
      iOS: DarwinNotificationDetails(),
    ),
    payload: m.data['bookingId'], // deep‑link id
  );
}

void _openBooking(String? bookingId) {
  if (bookingId != null) {
    navKey.currentState?.push(
      MaterialPageRoute(builder: (_) => PatientHomeScreen()),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.fcm});
  final String fcm;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mediora-Connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: MedicalLoginScreen(),
      home: MedioraSplashScreen(fcm: fcm),
      navigatorKey: navKey,
    );
  }
}

final navKey = GlobalKey<NavigatorState>();
