import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ==================== CHANNEL CONSTANTS ====================
  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDescription =
      'This channel is used for important notifications.';

  // ==================== INITIALIZE ====================
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // v21 — DarwinInitializationSettings has no permission params
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // v21 Android channel creation
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _createAndroidChannel();
    }

    print('✅ NotificationService initialized');
  }

  Future<void> _createAndroidChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    print('✅ Android notification channel created');
  }

  // ==================== NOTIFICATION TAP HANDLER ====================
  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    print('🔔 Notification tapped ID: ${response.id}');
    print('   Payload: ${response.payload}');
  }

  // ==================== PERMISSIONS ====================
  Future<bool> requestPermissions() async {
    print('🔐 Requesting notification permissions...');

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return await _requestAndroidPermissions();
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return await _requestIOSPermissions();
      }

      return false;
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      return false;
    }
  }

  Future<bool> _requestAndroidPermissions() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    print('🤖 Android SDK: $sdkInt');

    // Android 13+ — notification permission
    if (sdkInt >= 33) {
      final notifStatus = await Permission.notification.request();
      print('📋 Notification permission: $notifStatus');
      if (!notifStatus.isGranted) {
        print('❌ Notification permission denied');
        return false;
      }
    }

    // Android 12+ — exact alarm permission
    if (sdkInt >= 31) {
      final alarmStatus = await Permission.scheduleExactAlarm.request();
      print('📋 Exact alarm permission: $alarmStatus');
      if (!alarmStatus.isGranted) {
        print('⚠️ Exact alarm denied — notifications may be delayed');
      }
    }

    print('✅ Android permissions handled');
    return true;
  }

  Future<bool> _requestIOSPermissions() async {
    try {
      // For iOS, use the DarwinInitializationSettings approach
      // The requestPermissions method has changed in v21
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      print('📱 iOS permission result: $result');
      return result ?? false;
    } catch (e) {
      print('❌ iOS permission error: $e');
      return false;
    }
  }

  Future<bool> checkIOSPermissions() async {
    return _requestIOSPermissions();
  }

  // ==================== SCHEDULE REMINDER NOTIFICATION ====================
  Future<void> scheduleReminderNotification({
    required int id,
    required String title,
    required String body,
    required String amount,
    required String currency,
    required DateTime scheduledDate,
    required TimeOfDay scheduledTime,
    required String alertOption,
  }) async {
    try {
      // iOS permission check
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final hasPermission = await checkIOSPermissions();
        if (!hasPermission) {
          print('❌ iOS: Notification permissions not granted');
          return;
        }
      }

      // Combine date and time
      final DateTime reminderDateTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );

      // Subtract alert duration to get fire time
      final Duration alertDuration = _getAlertDuration(alertOption);
      final DateTime notificationDateTime = reminderDateTime.subtract(
        alertDuration,
      );

      _debugTimeCalculation(scheduledDate, scheduledTime, alertOption);

      if (notificationDateTime.isBefore(DateTime.now())) {
        print('⚠️ Notification time is in the past — skipping');
        return;
      }

      // Convert to device local timezone
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
        notificationDateTime,
        tz.local,
      );

      // Format amount with correct currency
      final String formattedAmount = _formatAmountForNotification(
        amount,
        currency,
      );

      // Build notification body
      String notificationBody = body;
      if (amount.isNotEmpty && amount != '0' && amount != '0.00') {
        notificationBody = 'Amount: $formattedAmount\n$body';
      }

      // Android details — v21
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            color: const Color(0xffC92B2B),
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap(
              '@mipmap/ic_launcher',
            ),
            styleInformation: BigTextStyleInformation(notificationBody),
          );

      // iOS details — v21
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // v21 zonedSchedule signature
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: notificationBody,
        scheduledDate: scheduledTZ,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('✅ Notification scheduled: $scheduledTZ');
      print('   Title: $title');
      print('   Body: $notificationBody');
      print('   Timezone: ${tz.local.name}');

      // Debug: list all pending notifications
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      print('📋 Total pending notifications: ${pending.length}');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  // ==================== SHOW IMMEDIATE NOTIFICATION ====================
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            color: Color(0xffC92B2B),
            icon: '@mipmap/ic_launcher',
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

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformDetails,
      );

      print('✅ Immediate notification shown: $title');
    } catch (e) {
      print('❌ Error showing immediate notification: $e');
    }
  }

  // ==================== CANCEL ====================
  Future<void> cancelScheduledNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
      print('✅ Cancelled notification ID: $id');
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  Future<void> cancelAllScheduledNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }

  // ==================== SHARED PLUGIN ACCESSOR ====================
  // PushNotificationService uses this so both share
  // the exact same plugin instance — prevents cancel mismatches
  static FlutterLocalNotificationsPlugin getNotificationsPlugin() {
    return _notificationsPlugin;
  }

  // ==================== HELPERS ====================
  Duration _getAlertDuration(String alertOption) {
    switch (alertOption) {
      case '5 minutes before':
        return const Duration(minutes: 5);
      case '10 minutes before':
        return const Duration(minutes: 10);
      case '15 minutes before':
        return const Duration(minutes: 15);
      case '30 minutes before':
        return const Duration(minutes: 30);
      case '1 hour before':
        return const Duration(hours: 1);
      case '2 hours before':
        return const Duration(hours: 2);
      case '1 day before':
        return const Duration(days: 1);
      case '2 days before':
        return const Duration(days: 2);
      case 'Default (5 minutes)':
      default:
        return const Duration(minutes: 5);
    }
  }

  String _formatAmountForNotification(String amount, String currency) {
    try {
      if (amount.isEmpty || amount == '0' || amount == '0.00') {
        return '';
      }
      final String cleaned = amount.replaceAll(',', '');
      final double number = double.parse(cleaned);
      return '$currency${NumberFormat('#,##0.00').format(number)}';
    } catch (e) {
      print('⚠️ Error formatting amount: $e');
      return '$currency$amount';
    }
  }

  void _debugTimeCalculation(
    DateTime scheduledDate,
    TimeOfDay scheduledTime,
    String alertOption,
  ) {
    final DateTime reminderDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
    final Duration alertDuration = _getAlertDuration(alertOption);
    final DateTime notificationDateTime = reminderDateTime.subtract(
      alertDuration,
    );

    print('=== TIME DEBUG ===');
    print('Reminder time    : $reminderDateTime');
    print('Alert option     : $alertOption');
    print('Alert duration   : $alertDuration');
    print('Notification time: $notificationDateTime');
    print('Current time     : ${DateTime.now()}');
    print(
      'In past?         : ${notificationDateTime.isBefore(DateTime.now())}',
    );
    print(
      'Time until       : ${notificationDateTime.difference(DateTime.now())}',
    );
    print('Local timezone   : ${tz.local.name}');
    print('=================');
  }
}
