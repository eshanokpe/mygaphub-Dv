// Create a new file: widgets/notification_handler.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/service/push_notification_service.dart';
import 'package:GapHub/provider/notification_provider.dart';

class NotificationHandler extends StatefulWidget {
  final Widget child;

  const NotificationHandler({super.key, required this.child});

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  final PushNotificationService _pushService = PushNotificationService();

  @override
  void initState() {
    super.initState();
    _setupNotificationListeners();
  }

  void _setupNotificationListeners() {
    // Listen for FCM messages when app is in foreground
    _pushService.onMessageReceived = (data) {
      print('📱 FCM message received in foreground: ${data['title']}');

      // Refresh notifications
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<NotificationProvider>();
        // provider.refreshNotifications();
      });

      // Show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'New notification: ${data['title'] ?? "New Message"}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    };

    // Listen for notification taps
    _pushService.onNotificationOpened = (data) {
      print('🔔 Notification opened: ${data['title']}');
      _handleNotificationTap(data);
    };
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final category = data['category'];
    final notificationId = data['notification_id'];

    print('📍 Handling notification tap: $category, ID: $notificationId');

    // Mark as read
    if (notificationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<NotificationProvider>();
        provider.markAsRead(notificationId);
      });
    }

    // Navigate based on category
    switch (category) {
      case 'seed_report':
        // Navigate to seed report
        break;
      case 'reminder':
        // Navigate to reminder
        break;
      // Add other cases as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
