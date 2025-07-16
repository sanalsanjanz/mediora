import 'package:flutter/material.dart';
import 'package:mediora/services/notification_service.dart';
import 'package:mediora/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  // final fcmToken = await NotificationService.getFcmToken();
  // print('FCM Token: $fcmToken');

  runApp(MyApp(fcm: ''));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.fcm});
  final String fcm;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Mediora-Connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MedioraSplashScreen(fcm: fcm),
    );
  }
}
