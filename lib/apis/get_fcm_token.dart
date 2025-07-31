import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<String?> getFcmToken() async {
    try {
      // iOS & Web: Request notification permissions
      if (Platform.isIOS || kIsWeb) {
        NotificationSettings settings = await _firebaseMessaging
            .requestPermission(alert: true, badge: true, sound: true);

        if (settings.authorizationStatus != AuthorizationStatus.authorized) {
          debugPrint("🔒 Notification permission denied on iOS/Web");
          return null;
        }
      }

      // Android 13+ requires runtime permission for notifications
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          PermissionStatus status = await Permission.notification.request();
          if (status != PermissionStatus.granted) {
            debugPrint("🔒 Notification permission not granted on Android 13+");
            return null;
          }
        }
      }

      // Get the FCM token
      String? token = await _firebaseMessaging.getToken();
      debugPrint("✅ FCM Token: $token");
      return token;
    } catch (e) {
      debugPrint("❌ Error getting FCM token: $e");
      return null;
    }
  }
}
