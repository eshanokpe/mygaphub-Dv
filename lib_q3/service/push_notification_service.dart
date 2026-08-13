import 'dart:convert';
import 'dart:math';

import 'package:GapHub/provider/notification_provider.dart';
import 'package:GapHub/screens/reminder/viewReminder.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_model.dart';
import '../screens/more/notifications/notification.dart';
import '../screens/more/notifications/notification_details.dart';
import 'notification_service.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      NotificationService.getNotificationsPlugin();

  // FCM Token for backend
  String? _fcmToken;
  Function(Map<String, dynamic>)? onMessageReceived;
  Function(Map<String, dynamic>)? onNotificationOpened;

  Future<void> initialize() async {
    await _setupLocalNotifications();
    await _requestPermissions();
    await _getFCMToken();
    _setupFirebaseListeners();
  }

  // ==================== LOCAL NOTIFICATIONS SETUP ====================
  Future<void> _setupLocalNotifications() async {
    // Android Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response);
      },
    );

    // Create notification channel for Android
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    print('✅ Local notifications initialized');
  }

  // ==================== PERMISSIONS ====================
  Future<void> _requestPermissions() async {
    try {
      // Request FCM permissions
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );

      print('📋 FCM Permission status: ${settings.authorizationStatus}');

      // For Android, also request local notification permissions
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          final status = await Permission.notification.request();
          print('📋 Android Notification Permission: $status');
        }
      }
    } catch (e) {
      print('❌ Permission request failed: $e');
    }
  }

  // ==================== FCM TOKEN MANAGEMENT ====================
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();

      if (_fcmToken != null) {
        print(
          '✅ FCM Token: ${_fcmToken!.substring(0, min(20, _fcmToken!.length))}...',
        );
        await _sendTokenToServer(_fcmToken);
      }
    } catch (e) {
      // Only log if it's NOT the APNS token error
      final errorStr = e.toString();
      if (!errorStr.contains('apns-token-not-set') &&
          !errorStr.contains('APNS token has not been received')) {
        print('❌ Failed to get FCM token: $e');
      } else {
        print(
          '📱 iOS APNS token not ready yet (normal) - will come via listener',
        );
      }
    }

    // Setup token refresh listener for iOS (and Android token changes)
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print(
        '🔄 FCM Token refreshed: ${newToken.substring(0, min(20, newToken.length))}...',
      );
      _fcmToken = newToken;
      _sendTokenToServer(newToken);
    });
  }

  Future<void> _sendTokenToServer(String? token) async {
    if (token == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      var userToken = prefs.getString('tokenDB');

      final response = await http.post(
        Uri.parse('$baseUrl/app/fcm-token'),
        headers: {
          "Authorization": 'Bearer $userToken',
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'fcm_token': token,
          'device_type': defaultTargetPlatform.toString(),
        }),
      );

      if (response.statusCode == 200) {
        print('✅ FCM token sent to server successfully');
      } else {
        print('❌ Failed to send FCM token to server: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error sending FCM token to server: $e');
    }
  }

  // ==================== FCM MESSAGE HANDLERS ====================
  void _setupFirebaseListeners() {
    // Handle messages when app is in FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 FOREGROUND MESSAGE RECEIVED');
      _handleForegroundMessage(message);
      // Explicitly trigger the callback
      if (onMessageReceived != null) {
        onMessageReceived!(message.data);
      }
    });

    // Handle when app is in BACKGROUND (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 BACKGROUND MESSAGE OPENED');
      _handleBackgroundMessage(message);
    });

    // Handle initial message when app is launched from TERMINATED state
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        print('📱 TERMINATED MESSAGE OPENED');
        _handleTerminatedMessage(message);
      }
    });

    print('✅ FCM Listeners setup complete');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('💬 Message received in foreground:');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');

    // Show local notification
    _showLocalNotification(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: message.data,
    );
    // Call callback if set
    if (onMessageReceived != null) {
      onMessageReceived!(message.data);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('💬 Background message opened:');
    print('   Data: ${message.data}');
    _navigateFromNotification(message.data);
  }

  void _handleTerminatedMessage(RemoteMessage message) {
    print('💬 Terminated message opened:');
    print('   Data: ${message.data}');
    // Call callback if set
    if (onNotificationOpened != null) {
      onNotificationOpened!(message.data);
    }
    _navigateFromNotification(message.data);
  }

  // ==================== NOTIFICATION TAP HANDLING ====================
  void _handleNotificationTap(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');

    try {
      if (response.payload != null) {
        final payload = jsonDecode(response.payload!) as Map<String, dynamic>;
        _navigateFromNotification(payload);
      }
    } catch (e) {
      print('❌ Error parsing notification payload: $e');
    }
  }

  void _navigateFromNotification(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    final idString =
        data['id']?.toString() ??
        data['reminder_id']?.toString() ??
        data['notification_id']?.toString();

    print('📍 Navigating from notification - Type: $type, ID: $idString');

    // Get context from navigator key
    final context = navigatorKey.currentContext;
    if (context == null) {
      print('⚠️ Context not available for navigation');
      return;
    }

    // Parse ID
    final id = int.tryParse(idString ?? '');
    if (id == null) {
      print('⚠️ Invalid notification ID');
      return;
    }

    // Mark as read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final provider = Provider.of<NotificationProvider>(
          context,
          listen: false,
        );
        provider.markAsRead(id);
      } catch (e) {
        print('⚠️ Could not mark notification as read: $e');
      }
    });

    // Navigate based on type
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentState == null ||
          !navigatorKey.currentState!.mounted) {
        return;
      }

      switch (type) {
        case 'reminder':
          navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (_) => ViewReminder(reminderId: id)),
          );
          break;

        case 'promotional':
        case 'system':
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              final provider = Provider.of<NotificationProvider>(
                context,
                listen: false,
              );
              final notification = provider.notifications.firstWhere(
                (n) => n.id == id,
                orElse: () => NotificationModel(
                  id: id,
                  title: data['title'] ?? 'Notification',
                  message: data['message'] ?? '',
                  seen: false,
                  category: data['category'] ?? '',
                  type: data['type'] ?? '',
                  data: data,
                  receivedAt: DateTime.now(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  userId: 0,
                  action: '',
                ),
              );

              navigatorKey.currentState!.push(
                MaterialPageRoute(
                  builder: (_) =>
                      NotificationDetailScreen(notification: notification),
                ),
              );
            } catch (e) {
              print('❌ Error getting notification: $e');
              // Fallback to general notifications screen
              navigatorKey.currentState!.push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            }
          });
          break;

        default:
          // Navigate to general notifications screen
          navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
          break;
      }
    });
  }

  Future<void> handleIncomingNotificationData(
    Map<String, dynamic> notificationData,
  ) async {
    print('📱 Handling incoming notification data: $notificationData');

    try {
      // Extract notification details
      final String title = notificationData['title'] ?? 'New Notification';
      final String message =
          notificationData['message'] ?? notificationData['body'] ?? '';
      final String category = notificationData['category'] ?? '';
      final String type = notificationData['type'] ?? '';

      // Generate a notification ID
      int notificationId =
          notificationData['notification_id'] ??
          (DateTime.now().millisecondsSinceEpoch % 1000000).toInt();

      // Handle data field
      Map<String, dynamic> data = {};
      if (notificationData['data'] != null) {
        if (notificationData['data'] is Map) {
          data = notificationData['data'] as Map<String, dynamic>;
        } else if (notificationData['data'] is String) {
          try {
            data = jsonDecode(notificationData['data'] as String);
          } catch (e) {
            print('Error parsing data string: $e');
          }
        }
      }

      // Create the payload for the notification
      final payload = {
        'type': type,
        'category': category,
        'data': jsonEncode(data),
        'title': title,
        'message': message,
        'notification_id': notificationId,
        'is_fetched': true,
      };

      // ALWAYS show notification even if app is in foreground
      print('📱 Showing notification: $title');

      // Create a safe ID
      final safeId = notificationId.hashCode.abs();

      // Show the notification
      await _showLocalNotification(
        id: safeId,
        title: title,
        body: message,
        payload: payload,
      );

      // Also trigger the onMessageReceived callback to update UI
      if (onMessageReceived != null) {
        print('🔔 Triggering onMessageReceived callback');
        onMessageReceived!(payload);
      }
    } catch (e) {
      print('❌ Error handling notification data: $e');
    }
  }

  // ==================== PUBLIC METHODS ====================
  String? get fcmToken => _fcmToken;

  /// SCHEDULE LOCAL NOTIFICATION (Primary Method)
  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduleTime,
    required Map<String, dynamic> payload,
  }) async {
    try {
      print('🎯 SCHEDULING LOCAL NOTIFICATION:');
      print('   ID: $id');
      print('   Title: $title');

      // Ensure timezone is initialized
      tz.initializeTimeZones();

      // Convert scheduleTime to local timezone
      final localScheduleTime = tz.TZDateTime.from(scheduleTime, tz.local);
      final now = tz.TZDateTime.now(tz.local);

      final secondsUntil = localScheduleTime.difference(now).inSeconds;
      print('   Local Schedule Time: $localScheduleTime');
      print('   Current Local Time: $now');
      print('   Seconds until: $secondsUntil');

      if (secondsUntil <= 0) {
        print('⚠️ Cannot schedule in the past');
        return;
      }

      // For debugging: print timezone info
      print('   Timezone: ${tz.local.name}');
      print('   Is UTC: ${tz.local.name == 'UTC'}');

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            color: Color(0xffC92B2B),
            timeoutAfter: 60000, // 1 minute timeout
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // v21 - Use named parameters for zonedSchedule
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: localScheduleTime,
        notificationDetails: platformDetails,
        payload: jsonEncode(payload),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('✅ Local notification scheduled!');
      print('   Will appear in: $secondsUntil seconds');

      // Debug: Check pending notifications
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      print('📋 Total pending notifications: ${pending.length}');
    } catch (e) {
      print('❌ Error scheduling local notification: $e');
      print('Stack trace: ${e.toString()}');
    }
  }

  /// DUAL STRATEGY: Local + Backend FCM
  Future<void> scheduleDualNotification({
    required int reminderId,
    required String title,
    required String body,
    required DateTime scheduleTime,
    required String amount,
    required String currency,
    String? note,
  }) async {
    try {
      print('🔔 DUAL NOTIFICATION SCHEDULING STARTED');
      print('   Reminder ID: $reminderId');
      print('   Title: $title');
      print('   Schedule Time: $scheduleTime');
      print('   Currency: $currency');

      // Format amount with currency
      final formattedAmount = '$currency$amount';

      // 1. Schedule Local Notification
      await scheduleLocalNotification(
        id: reminderId,
        title: title,
        body: note?.isNotEmpty == true
            ? '$note - Amount: $formattedAmount'
            : 'Reminder: $title - Amount: $formattedAmount',
        scheduleTime: scheduleTime,
        payload: {
          'type': 'reminder',
          'reminder_id': reminderId,
          'title': title,
          'body': note ?? '',
          'amount': formattedAmount,
          'currency': currency,
          'action': 'view_reminder',
        },
      );

      print('✅ Dual notification strategy deployed');
    } catch (e) {
      print('❌ Error in dual scheduling: $e');
    }
  }

  /// CANCEL NOTIFICATIONS
  Future<void> cancelScheduledNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
      print('✅ Cancelled scheduled notification with ID: $id');
    } catch (e) {
      print('❌ Error cancelling scheduled notification: $e');
    }
  }

  Future<void> cancelDualNotification(int reminderId) async {
    try {
      print('🗑️ CANCELLING NOTIFICATIONS:');
      print('   Reminder ID: $reminderId');

      // Cancel local notification
      await cancelScheduledNotification(reminderId);
      print('   ✅ Local notification cancelled');

      // Request backend to cancel FCM
      await _requestBackendFCMCancellation(reminderId);
      print('   ✅ Backend cancellation requested');
    } catch (e) {
      print('❌ Error cancelling notifications: $e');
    }
  }

  Future<void> _requestBackendFCMCancellation(int reminderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('tokenDB');

      if (userToken == null) return;

      await http.post(
        Uri.parse('$baseUrl/app/cancel-reminder-fcm'),
        headers: {
          "Authorization": 'Bearer $userToken',
          "Accept": "application/json",
        },
        body: jsonEncode({'reminder_id': reminderId}),
      );
    } catch (e) {
      print('⚠️ Error requesting backend cancellation: $e');
    }
  }

  /// SHOW IMMEDIATE NOTIFICATION
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final safeId = id.abs() % 2147483647;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: 'ic_launcher',
            color: Color(0xffC92B2B),
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // v21 - Use named parameters for show
      await _notificationsPlugin.show(
        id: safeId,
        title: title,
        body: body,
        notificationDetails: platformDetails,
        payload: jsonEncode(payload),
      );

      print('✅ Local notification shown: $title');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }
}
