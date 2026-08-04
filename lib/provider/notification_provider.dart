// providers/notification_provider.dart
import 'package:GapHub/service/push_notification_service.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';
import 'reminderProvider.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  // Add a reference to PushNotificationService
  final PushNotificationService _pushService = PushNotificationService();
  final ReminderProvider _reminderProvider;
  NotificationProvider(this._reminderProvider);

  // Add these private variables with the other state variables
  int _total = 0;
  int _lastPage = 1;
  int _from = 0;
  int _to = 0;

  // Add these getters
  int get total => _total;
  int get lastPage => _lastPage;
  int get currentPage => _currentPage;
  int get from => _from;
  int get to => _to;
  int get perPage => _perPage;

  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _perPage = 10;
  int _unreadCount = 0;
  bool _initialLoadDone = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get unreadCount => _unreadCount;
  bool get initialLoadDone => _initialLoadDone; // Add this getter

  // Add this method to force initial load
  Future<void> ensureInitialLoad(String currency) async {
    if (!_initialLoadDone && !_isLoading) {
      await fetchNotifications(refresh: true);
      await _reminderProvider.fetchReminders(currency);
      _initialLoadDone = true;
    }
  }

  // Fix the fetchNotifications method
  Future<void> fetchNotifications({
    bool refresh = false,
    bool silent = false,
    bool append = false,
  }) async {
    if (_isLoading && !refresh) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
      }

      _isLoading = true;
      if (!silent) notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      final response = await http.get(
        Uri.parse(
          '$baseUrl/app/notifications?page=$_currentPage&per_page=$_perPage',
        ),
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success']) {
          final data = responseData['data'];
          // print("dataNotification:${data['data']}");
          final List<dynamic> notificationData = data['data'];

          final List<NotificationModel> fetchedNotifications = notificationData
              .map((item) => NotificationModel.fromJson(item))
              .toList();

          // Track pagination metadata
          _total = data['total'] ?? 0;
          _lastPage = data['last_page'] ?? 1;
          _from = data['from'] ?? 0;
          _to = data['to'] ?? 0;

          if (append && _currentPage > 1) {
            final existingIds = _notifications.map((item) => item.id).toSet();
            _notifications.addAll(
              fetchedNotifications.where(
                (notification) => !existingIds.contains(notification.id),
              ),
            );
          } else {
            _notifications = fetchedNotifications;
          }

          _hasMore = data['next_page_url'] != null;
          _unreadCount = responseData['unread_count'] ?? 0;

          // Sort notifications by date (newest first)
          _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
      }
    } catch (error) {
      print('Error fetching notifications: $error');
    } finally {
      _isLoading = false;
      if (!silent) notifyListeners();
    }
  }

  // Fix the navigation methods
  Future<void> goToNextPage() async {
    if (_hasMore && !_isLoading) {
      _currentPage++; // Increment page first
      await fetchNotifications(append: true); // Fetch the new page
    }
  }

  Future<void> goToPreviousPage() async {
    if (_currentPage > 1 && !_isLoading) {
      _currentPage--; // Decrement page first
      await fetchNotifications(); // Fetch the new page
    }
  }

  Future<void> goToPage(int page) async {
    if (page != _currentPage && !_isLoading && page > 0 && page <= _lastPage) {
      _currentPage = page; // Set the new page
      await fetchNotifications(); // Fetch that page
    }
  }

  // Fix the refresh method - this should reset to page 1
  Future<void> refreshNotifications() async {
    _currentPage = 1; // Reset to page 1
    _hasMore = true;
    await fetchNotifications(refresh: true);
  }

  // Add this helper method
  Future<void> _showNotificationAsPush(NotificationModel notification) async {
    try {
      if (notification.seen) {
        print(
          '⏭️ Skipping push for already read notification: ${notification.id}',
        );
        return;
      }
      final notificationData = {
        'title': notification.title,
        'message': notification.message,
        'category': notification.category,
        'type': notification.type ?? '',
        'data': notification.data ?? {},
        'notification_id': notification.id,
        'received_at': notification.receivedAt.toIso8601String(),
        'created_at': notification.createdAt.toIso8601String(),
      };

      // print('🚀 Showing push notification: ${notification.title}');

      // Use the push service to show notification
      await _pushService.handleIncomingNotificationData(notificationData);
    } catch (e) {
      print('❌ Error showing push notification: $e');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      final response = await http.post(
        Uri.parse('$baseUrl/app/notifications/$notificationId/mark-as-read'),
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] ?? false) {
          final index = _notifications.indexWhere(
            (n) => n.id == notificationId,
          );
          if (index != -1) {
            // Update the notification in the list
            _notifications[index] = NotificationModel(
              id: _notifications[index].id,
              userId: _notifications[index].userId,
              action: _notifications[index].action,
              title: _notifications[index].title,
              message: _notifications[index].message,
              seen: true,
              category: _notifications[index].category,
              type: _notifications[index].type,
              data: _notifications[index].data,
              receivedAt: _notifications[index].receivedAt,
              readAt: DateTime.now(),
              createdAt: _notifications[index].createdAt,
              updatedAt: _notifications[index].updatedAt,
            );

            // Update unread count
            _unreadCount =
                responseData['unread_count'] ??
                (_unreadCount > 0 ? _unreadCount - 1 : 0);
            notifyListeners();
          }
        }
      }
    } catch (error) {
      print('Error marking notification as read: $error');
      // Handle error (show snackbar, etc.)
    }
  }

  Future<void> markAllAsRead({List<int>? notificationIds}) async {
    try {
      Map<String, dynamic> requestBody = {};

      if (notificationIds != null && notificationIds.isNotEmpty) {
        // If specific IDs are provided
        requestBody['notification_ids'] = notificationIds;
      }
      // If no IDs are provided, it will mark all as read
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      final response = await http.post(
        Uri.parse('$baseUrl/app/notifications/$notificationIds/mark-all-read'),
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] ?? false) {
          if (notificationIds != null && notificationIds.isNotEmpty) {
            // Mark specific notifications as read
            for (int i = 0; i < _notifications.length; i++) {
              if (notificationIds.contains(_notifications[i].id)) {
                _notifications[i] = NotificationModel(
                  id: _notifications[i].id,
                  userId: _notifications[i].userId,
                  action: _notifications[i].action,
                  title: _notifications[i].title,
                  message: _notifications[i].message,
                  seen: true,
                  category: _notifications[i].category,
                  type: _notifications[i].type,
                  data: _notifications[i].data,
                  receivedAt: _notifications[i].receivedAt,
                  readAt: DateTime.now(),
                  createdAt: _notifications[i].createdAt,
                  updatedAt: _notifications[i].updatedAt,
                );
              }
            }
          } else {
            // Mark all notifications as read
            _notifications = _notifications.map((notification) {
              return NotificationModel(
                id: notification.id,
                userId: notification.userId,
                action: notification.action,
                title: notification.title,
                message: notification.message,
                seen: true,
                category: notification.category,
                type: notification.type,
                data: notification.data,
                receivedAt: notification.receivedAt,
                readAt: DateTime.now(),
                createdAt: notification.createdAt,
                updatedAt: notification.updatedAt,
              );
            }).toList();
          }

          // Update unread count from response
          _unreadCount = responseData['unread_count'] ?? 0;
          notifyListeners();
        }
      }
    } catch (error) {
      print('Error marking all notifications as read: $error');
      // Handle error
    }
  }

  // Helper method to get all unread notification IDs
  List<int> getUnreadNotificationIds() {
    return _notifications
        .where((notification) => !notification.seen)
        .map((notification) => notification.id)
        .toList();
  }

  // Method to mark all visible unread notifications as read
  Future<void> markVisibleUnreadAsRead() async {
    final unreadIds = getUnreadNotificationIds();
    if (unreadIds.isNotEmpty) {
      await markAllAsRead(notificationIds: unreadIds);
    }
  }

  void clearNotifications() {
    _notifications.clear();
    _currentPage = 1;
    _hasMore = true;
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      final response = await http.delete(
        Uri.parse('$baseUrl/app/notifications/$notificationId'),
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] ?? false) {
          // Remove from local list
          _notifications.removeWhere((n) => n.id == notificationId);

          // Update unread count if needed
          final notification = _notifications.firstWhere(
            (n) => n.id == notificationId,
            orElse: () => NotificationModel(
              id: 0,
              userId: 0,
              title: '',
              message: '',
              seen: true,
              category: '',
              type: '',
              data: {},
              receivedAt: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          if (!notification.seen) {
            _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
          }

          notifyListeners();
          return;
        }
      }

      print('❌ Failed to delete notification: ${response.statusCode}');
      throw Exception('Failed to delete notification: ${response.statusCode}');
    } catch (error) {
      print('❌ Error deleting notification: $error');
      rethrow;
    }
  }

  Future<void> deleteMultipleNotifications(List<int> notificationIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      // Delete notifications one by one
      final List<Future> deleteFutures = [];
      final List<int> successfullyDeleted = [];

      for (final id in notificationIds) {
        deleteFutures.add(
          http
              .delete(
                Uri.parse('$baseUrl/app/notifications/$id'),
                headers: {
                  "Authorization": 'Bearer $token',
                  "Accept": "application/json",
                },
              )
              .then((response) {
                if (response.statusCode == 200) {
                  final responseData = json.decode(response.body);
                  if (responseData['success'] ?? false) {
                    successfullyDeleted.add(id);
                  }
                }
              })
              .catchError((error) {
                print('❌ Error deleting notification $id: $error');
              }),
        );
      }

      // Wait for all delete operations to complete
      await Future.wait(deleteFutures);

      // Remove deleted notifications from local list
      _notifications.removeWhere((n) => successfullyDeleted.contains(n.id));

      // Update unread count
      final deletedUnreadCount = _notifications
          .where((n) => successfullyDeleted.contains(n.id) && !n.seen)
          .length;

      _unreadCount = _unreadCount > deletedUnreadCount
          ? _unreadCount - deletedUnreadCount
          : 0;

      notifyListeners();

      if (successfullyDeleted.length != notificationIds.length) {
        throw Exception('Some notifications could not be deleted');
      }
    } catch (error) {
      print('❌ Error deleting multiple notifications: $error');
      rethrow;
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      // First, get all notification IDs
      final allIds = _notifications.map((n) => n.id).toList();

      // Delete all notifications
      await deleteMultipleNotifications(allIds);
    } catch (error) {
      print('❌ Error deleting all notifications: $error');
      rethrow;
    }
  }

  // Helper method to delete by category
  Future<void> deleteNotificationsByCategory(String category) async {
    try {
      final notificationsToDelete = _notifications
          .where((n) => n.category == category)
          .map((n) => n.id)
          .toList();

      if (notificationsToDelete.isNotEmpty) {
        await deleteMultipleNotifications(notificationsToDelete);
      }
    } catch (error) {
      print('❌ Error deleting notifications by category: $error');
      rethrow;
    }
  }
}
