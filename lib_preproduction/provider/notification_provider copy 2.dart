import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/notification_model.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _perPage = 20;
  String? _error;

  // Stream for real-time updates
  final StreamController<NotificationModel> _notificationStreamController =
      StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get notificationStream =>
      _notificationStreamController.stream;

  // FCM and local notifications
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _authToken;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  NotificationProvider() {
    _initFromStorage();
  }

  // ================ INITIALIZATION ================

  Future<void> _initFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('notifications');

      if (stored != null) {
        final List<dynamic> decoded = json.decode(stored);
        _notifications = decoded
            .map((n) => NotificationModel.fromMap(n))
            .toList();
        _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error initializing from storage: $e');
    }
  }

  // ================ NOTIFICATION MANAGEMENT ================

  // Add incoming notification
  void addIncomingNotification(Map<String, dynamic> data) {
    try {
      final notification = NotificationModel.fromMap(data);

      // Check if already exists
      final existingIndex = _notifications.indexWhere(
        (n) => n.id == notification.id,
      );

      if (existingIndex == -1) {
        // Add to beginning
        _notifications.insert(0, notification);

        if (!notification.seen) {
          _unreadCount++;
        }

        // Save to storage
        _saveToStorage();

        // Broadcast via stream
        _notificationStreamController.add(notification);

        notifyListeners();
      }
    } catch (e) {
      print('❌ Error adding incoming notification: $e');
    }
  }

  // Add background notification
  void addBackgroundNotification(Map<String, dynamic> data) {
    addIncomingNotification(data);
  }

  // Add multiple background notifications
  void addBackgroundNotifications(List<Map<String, dynamic>> notificationList) {
    for (var notification in notificationList) {
      addBackgroundNotification(notification);
    }
  }

  // ================ API METHODS ================

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_isLoading) return;

    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('tokenDB');

    if (userToken == null) {
      print('⚠️ User not authenticated');
      return;
    }

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _notifications.clear();
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/app/notifications?page=$_currentPage&per_page=$_perPage',
        ),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bool success = data['success'] ?? false;

        if (success) {
          final responseData = data['data'];
          final List<dynamic> apiNotifications = responseData['data'] ?? [];

          // Update pagination
          _currentPage = responseData['current_page'] ?? _currentPage;
          final lastPage = responseData['last_page'] ?? _currentPage;
          _hasMore = _currentPage < lastPage;

          // Process notifications
          for (var apiNotif in apiNotifications) {
            try {
              final notification = NotificationModel.fromJson(apiNotif);

              final existingIndex = _notifications.indexWhere(
                (n) => n.id == notification.id,
              );

              if (existingIndex == -1) {
                _notifications.add(notification);
              } else {
                _notifications[existingIndex] = notification;
              }
            } catch (e) {
              print('❌ Error parsing notification: $e');
            }
          }

          // Update unread count
          _unreadCount = data['unread_count'] ?? _calculateUnreadCount();

          // Sort by date (newest first)
          _notifications.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

          // Increment page
          if (_hasMore) {
            _currentPage++;
          }

          // Save to storage
          await _saveToStorage();
        } else {
          _error = data['message'] ?? 'Failed to fetch notifications';
        }
      } else {
        _error = 'Failed to fetch notifications: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final updated = _notifications[index].copyWith(
          seen: true,
          readAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        _notifications[index] = updated;
        _updateUnreadCount();
        await _saveToStorage();
        notifyListeners();

        // Mark on server
        await _markAsReadOnServer(notificationId);
      }
    } catch (e) {
      print('❌ Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead({List<int>? notificationIds}) async {
    try {
      if (notificationIds == null || notificationIds.isEmpty) {
        // Mark all
        for (int i = 0; i < _notifications.length; i++) {
          _notifications[i] = _notifications[i].copyWith(
            seen: true,
            readAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      } else {
        // Mark specific
        for (var id in notificationIds) {
          final index = _notifications.indexWhere((n) => n.id == id);
          if (index != -1) {
            _notifications[index] = _notifications[index].copyWith(
              seen: true,
              readAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        }
      }

      _updateUnreadCount();
      await _saveToStorage();
      notifyListeners();

      // Mark on server
      await _markAllAsReadOnServer();
    } catch (e) {
      print('❌ Error marking all as read: $e');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      final response = await http.delete(
        Uri.parse('$baseUrl/app/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] ?? false) {
          _notifications.removeWhere((n) => n.id == notificationId);
          _updateUnreadCount();
          await _saveToStorage();
          notifyListeners();
        }
      }
    } catch (e) {
      print('❌ Error deleting notification: $e');
      rethrow;
    }
  }

  // ================ FCM TOKEN MANAGEMENT ================

  void setAuthToken(String token) {
    _authToken = token;
  }

  Future<void> saveFcmToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      await prefs.setString(
        'fcm_token_saved_at',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  Future<void> registerDeviceToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token');
      final userToken = prefs.getString('tokenDB');

      if (token != null && userToken != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/app/fcm-token'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userToken',
          },
          body: json.encode({
            'fcm_token': token,
            'device_type': Platform.isAndroid ? 'android' : 'ios',
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('✅ FCM token registered with server');
        }
      }
    } catch (e) {
      print('❌ Error registering device token: $e');
    }
  }

  // ================ UTILITY METHODS ================

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsList = _notifications.map((n) => n.toMap()).toList();
      await prefs.setString('notifications', json.encode(notificationsList));
    } catch (e) {
      print('❌ Error saving to storage: $e');
    }
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.seen).length;
  }

  int _calculateUnreadCount() {
    return _notifications.where((n) => !n.seen).length;
  }

  NotificationModel? getNotificationById(int id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  List<int> getUnreadNotificationIds() {
    return _notifications.where((n) => !n.seen).map((n) => n.id).toList();
  }

  bool hasNotification(int id) {
    return _notifications.any((n) => n.id == id);
  }

  Map<String, int> getNotificationStats() {
    final total = _notifications.length;
    final unread = _unreadCount;
    final read = total - unread;

    return {'total': total, 'unread': unread, 'read': read};
  }

  // ================ SERVER COMMUNICATION ================

  Future<void> _markAsReadOnServer(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('tokenDB');

      if (userToken == null) return;

      final response = await http.post(
        Uri.parse('$baseUrl/app/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print('⚠️ Failed to mark as read on server');
      }
    } catch (e) {
      print('❌ Error marking as read on server: $e');
    }
  }

  Future<void> _markAllAsReadOnServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('tokenDB');

      if (userToken == null) return;

      final response = await http.post(
        Uri.parse('$baseUrl/app/notifications/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print('⚠️ Failed to mark all as read on server');
      }
    } catch (e) {
      print('❌ Error marking all as read on server: $e');
    }
  }

  @override
  void dispose() {
    _notificationStreamController.close();
    super.dispose();
  }
}
