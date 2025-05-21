import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tufan_rider/core/di/locator.dart';
import 'package:tufan_rider/core/network/api_service.dart';
import 'package:tufan_rider/features/auth/cubit/auth_cubit.dart';

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission for notifications
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    sendTokenToServer();
    // Initialize local notifications
    await _initLocalNotifications();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // Handle when the app is opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('App opened from terminated state via notification');
      }
    });

    // Handle app open from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background via notification');
    });
  }

  // Send FCM token to your backend server
  Future<void> sendTokenToServer() async {
    try {
      final loginResponse = locator.get<AuthCubit>().loginResponse;

      if (loginResponse == null) {
        print("user is not authenticated");
        return;
      }

      // Get FCM token
      String? fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $fcmToken');

      if (fcmToken == null) {
        print('no fcm token');
        return;
      }

      final response = await ApiService().updateFcmToken(
          loginResponse.user.id.toString(), loginResponse.token, fcmToken);
      if (response.statusCode == 200) {
        print('FCM token successfully sent to server');
      } else {
        print('Failed to send FCM token. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending FCM token: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        print('Notification tapped with payload: ${response.payload}');
      },
    );

    // Create Android channel
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is for important notifications.',
      importance: Importance.high,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Handling background message: ${message.notification?.title}');
    print(message.notification?.body);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (message.notification != null &&
        message.notification!.title != null &&
        message.notification!.body != null) {
      await _localNotificationsPlugin.show(
        0,
        message.notification!.title,
        message.notification!.body,
        platformDetails,
      );
    }
  }
}
