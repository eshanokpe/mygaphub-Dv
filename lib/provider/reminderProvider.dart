import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:GapHub/models/remindermodel.dart';
import 'package:GapHub/service/push_notification_service.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReminderProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<ReminderModel> _reminders = [];
  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int _reminderCount = 0;
  int get reminderCount => _reminderCount;
  final PushNotificationService _pushNotificationService =
      PushNotificationService();

  // ==================== CREATE REMINDER ====================
  Future<bool> createReminder({
    required String title,
    required String note,
    required String amount,
    required DateTime? date,
    required TimeOfDay? time,
    required String alert,
    required String currency,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate required fields
      if (title.isEmpty) {
        _error = 'Title is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (date == null) {
        _error = 'Date is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (time == null) {
        _error = 'Time is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      const one = "1";
      const zero = "0";

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'name': title.trim(),
        'amount': _parseAmountAsString(amount),
        'date': _formatDateForAPI(date),
        'time': _formatTimeForAPI(time),
        'alert_days_before': _parseAlertDaysBeforeAsString(alert),
        "email": one,
        "sms": zero,
        "push": one,
      };

      // Add note only if it's not empty
      final trimmedNote = note.trim();
      if (trimmedNote.isNotEmpty) {
        requestBody['note'] = trimmedNote;
      }

      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      final response = await http
          .post(
            Uri.parse('$baseUrl/app/options/reminders'),
            headers: {
              "Authorization": 'Bearer $token',
              "Accept": "application/json",
              "Cache-Control": "no-cache",
              "Connection": "keep-alive",
            },
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == true) {
          // Small delay to ensure server consistency
          await Future.delayed(const Duration(milliseconds: 300));

          // Fire and forget - don't wait for this to complete
          unawaited(
            fetchReminders(currency, force: true).catchError((e) {
              print('Background fetch failed: $e');
            }),
          );

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          final message =
              responseData['message'] ?? 'Failed to create reminder';
          if (message.toLowerCase().contains('too many') ||
              message.toLowerCase().contains('rate limit') ||
              message.toLowerCase().contains('attempt')) {
            _error = 'Please wait a moment before trying again';
          } else {
            _error = message;
          }
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else if (response.statusCode == 429) {
        _error = 'Too many attempts. Please wait and try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        final errorData = jsonDecode(response.body);
        if (errorData['data'] != null) {
          _error = _formatValidationErrors(errorData['data']);
        } else {
          _error =
              errorData['message'] ??
              'Failed to create reminder: ${response.statusCode}';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on TimeoutException {
      _error = 'Request timed out. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on SocketException {
      _error = 'No internet connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== FETCH REMINDERS ====================
  Future<void> fetchReminders(String currency, {bool force = false}) async {
    if (_isLoading && !force) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null || token.isEmpty) {
        _isLoading = false;
        _error = 'Session expired. Please login again.';
        notifyListeners();
        return;
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/app/options/reminders'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == true) {
          final remindersData = responseData['data']['reminders']['data'];
          print("Reminder List: $remindersData");

          final newReminders = (remindersData as List)
              .map((item) => ReminderModel.fromJson(item))
              .toList();

          _reminders = newReminders;
          _reminderCount = _reminders.length;

          // Schedule notifications in the background without awaiting
          unawaited(_scheduleAllReminderNotifications(currency));

          print('✅ Fetched ${_reminders.length} reminders');
        } else {
          _error = responseData['message'] ?? 'Failed to fetch reminders';
        }
      } else {
        _error = 'Failed to fetch reminders (${response.statusCode})';
      }
    } on TimeoutException catch (_) {
      _error = 'Request timeout. Please try again.';
    } on SocketException catch (_) {
      _error = 'No internet connection';
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== FETCH REMINDER BY ID ====================
  Future<ReminderModel?> fetchReminderById(int reminderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null || token.isEmpty) {
        _isLoading = false;
        _error = 'Session expired. Please login again.';
        notifyListeners();
        return null;
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/app/options/reminders/$reminderId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      _isLoading = false;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Fetch Reminder By ID Response: $responseData");

        if (responseData['status'] == true) {
          final reminderData = responseData['data'];
          return ReminderModel.fromJson(reminderData);
        } else {
          _error = responseData['message'] ?? 'Failed to fetch reminder';
          notifyListeners();
          return null;
        }
      } else {
        _error = 'Failed to fetch reminder (${response.statusCode})';
        notifyListeners();
        return null;
      }
    } on TimeoutException catch (_) {
      _isLoading = false;
      _error = 'Request timeout. Please try again.';
      notifyListeners();
      return null;
    } on SocketException catch (_) {
      _isLoading = false;
      _error = 'No internet connection';
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Network error: $e';
      notifyListeners();
      return null;
    }
  }

  // ==================== SCHEDULE NOTIFICATIONS ====================
  Future<void> _scheduleAllReminderNotifications(String currency) async {
    print('🔄 Scheduling notifications for ${_reminders.length} reminders');

    int scheduledCount = 0;

    for (var reminder in _reminders) {
      // Only schedule if reminder is not completed and not past
      if (reminder.complete == 0 && !reminder.isPast) {
        final success = await _scheduleSingleReminderNotification(
          reminder,
          currency,
        );
        if (success) scheduledCount++;
      }
    }

    print('📊 Scheduled notifications: $scheduledCount/${_reminders.length}');
  }

  Future<bool> _scheduleSingleReminderNotification(
    ReminderModel reminder,
    String currency,
  ) async {
    try {
      if (reminder.alertDate == null || reminder.alertDate!.isEmpty) {
        print('⚠️ No alert_date for reminder ID: ${reminder.id}');
        return false;
      }

      final alertDateTime = _parseDateTimeString(reminder.alertDate!);
      final now = DateTime.now();

      if (alertDateTime.isAfter(now)) {
        // Cancel any existing notifications first
        await _pushNotificationService.cancelDualNotification(reminder.id);

        // Schedule new notification
        await _pushNotificationService.scheduleDualNotification(
          reminderId: reminder.id,
          title: reminder.name,
          body: 'Reminder',
          scheduleTime: alertDateTime,
          amount: reminder.amount?.toString() ?? '0',
          currency: currency,
          note: reminder.note ?? '',
        );

        print('✅ Notification scheduled for reminder ID: ${reminder.id}');
        return true;
      } else {
        print('⚠️ Alert time has passed for reminder ID: ${reminder.id}');
        return false;
      }
    } catch (e) {
      print('❌ Error scheduling notification for reminder ${reminder.id}: $e');
      return false;
    }
  }

  // ==================== DELETE REMINDER ====================
  Future<bool> deleteReminder(int reminderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      final response = await http.delete(
        Uri.parse('$baseUrl/app/options/reminders/$reminderId'),
        headers: {
          'Content-Type': 'application/json',
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == true) {
          // Cancel notifications
          await _pushNotificationService.cancelDualNotification(reminderId);

          // Remove from local list
          _reminders.removeWhere((reminder) => reminder.id == reminderId);
          _reminderCount = _reminders.length;

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = responseData['message'] ?? 'Failed to delete reminder';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Failed to delete reminder: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== MARK AS COMPLETE ====================
  Future<bool> markReminderAsComplete(
    int reminderId,
    String name,
    String note,
    String amount,
    DateTime? date,
    TimeOfDay? time,
    int alert,
    String currency,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      final response = await http.patch(
        Uri.parse('$baseUrl/app/options/reminders/$reminderId'),
        headers: {
          'Content-Type': 'application/json',
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'note': note,
          'date': date != null ? _formatDateForAPI(date) : null,
          'time': time != null ? _formatTimeForAPI(time) : null,
          'amount': amount,
          'alert_days_before': alert.toString(),
          'mark_as_completed': true,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == true) {
          // Cancel notifications
          await _pushNotificationService.cancelDualNotification(reminderId);

          // Refresh reminders in background
          unawaited(
            fetchReminders(currency).catchError((e) {
              print('Background fetch failed: $e');
            }),
          );

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = responseData['message'] ?? 'Failed to complete reminder';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Failed to complete reminder: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== UPDATE REMINDER ====================
  Future<bool> updateReminder({
    required int id,
    required String title,
    required String note,
    required String amount,
    required DateTime date,
    required TimeOfDay time,
    required String alert,
    required String currency,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate required fields
      if (title.isEmpty) {
        _error = 'Title is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      const one = "1";
      const zero = "0";
      print("alert: $alert");

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'name': title.trim(),
        'amount': _parseAmountAsString(amount),
        'date': _formatDateForAPI(date),
        'time': _formatTimeForAPI(time),
        'alert_days_before': _parseAlertDaysBeforeAsString(alert),
        "email": one,
        "sms": zero,
        "push": one,
      };

      // Add note only if it's not empty
      final trimmedNote = note.trim();
      if (trimmedNote.isNotEmpty) {
        requestBody['note'] = trimmedNote;
      }

      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');

      print('Updating reminder with ID: $id');
      print('Sending request body: $requestBody');

      final response = await http.patch(
        Uri.parse('$baseUrl/app/options/reminders/$id'),
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: requestBody,
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == true) {
          // Cancel existing notifications first
          await _pushNotificationService.cancelDualNotification(id);

          // Refresh the reminders list in background
          unawaited(
            fetchReminders(currency).catchError((e) {
              print('Background fetch failed: $e');
            }),
          );

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          // Extract validation errors and format them for display
          if (responseData['data'] != null) {
            final validationErrors = responseData['data'];
            print('Validation errors: $validationErrors');
            _error = _formatValidationErrors(validationErrors);
          } else {
            _error = responseData['data'] ?? 'Failed to update reminder';
          }
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        final errorData = jsonDecode(response.body);
        if (errorData['data'] != null) {
          final validationErrors = errorData['data'];
          if (validationErrors is Map<String, dynamic>) {
            _error = _formatValidationErrors(validationErrors);
          } else if (validationErrors is String) {
            _error = validationErrors;
          } else {
            _error = validationErrors.toString();
          }
        } else {
          _error =
              errorData['message'] ??
              'Failed to update reminder: ${response.statusCode}';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      print('Network error during update: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== HELPER METHODS ====================
  String _parseAmountAsString(String amount) {
    // Handle null or empty
    if (amount.isEmpty) {
      print('⚠️ Amount is empty, returning 0');
      return "0"; // Changed from "0.00"
    }

    // Remove commas and trim whitespace
    final cleanedAmount = amount.replaceAll(',', '').trim();

    // Check if after cleaning it's empty or just "0"
    if (cleanedAmount.isEmpty ||
        cleanedAmount == "0" ||
        cleanedAmount == "0.0") {
      print(
        '⚠️ Amount after cleaning is zero/empty: "$amount" -> "$cleanedAmount", returning 0',
      );
      return "0"; // Changed from "0.00"
    }

    // Try to parse as number to validate
    try {
      final parsed = double.parse(cleanedAmount);
      if (parsed == 0) {
        print(
          '⚠️ Parsed amount is zero: "$amount" -> "$cleanedAmount" -> $parsed, returning 0',
        );
        return "0"; // Changed from "0.00"
      }
      print(
        '✅ Amount parsed successfully: original="$amount", cleaned="$cleanedAmount", parsed=$parsed',
      );
      return cleanedAmount;
    } catch (e) {
      // If parsing fails, return 0
      print(
        '❌ Invalid amount format: "$amount" -> "$cleanedAmount", error: $e, returning 0',
      );
      return "0"; // Changed from "0.00"
    }
  }

  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTimeForAPI(TimeOfDay time) {
    print(
      'time:${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}}',
    );
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _parseAlertDaysBeforeAsString(String alert) {
    switch (alert) {
      case "5 minutes before":
        return "5 minutes";
      case "10 minutes before":
        return "10 minutes";
      case "15 minutes before":
        return "15 minutes";
      case "30 minutes before":
        return "30 minutes";
      case "1 hour before":
        return "1 hour";
      case "2 hours before":
        return "2 hours";
      case "1 day before":
        return "1 day";
      case "2 days before":
        return "2 days";
      case "Default (5 minutes)":
      default:
        return "5 minutes";
    }
  }

  DateTime _parseDateTimeString(String dateTimeString) {
    try {
      // Format: "2025-12-28 19:52:00"
      final parts = dateTimeString.split(' ');
      if (parts.length == 2) {
        final dateParts = parts[0].split('-');
        final timeParts = parts[1].split(':');

        if (dateParts.length == 3 && timeParts.length >= 2) {
          return DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
            timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
          );
        }
      }

      return DateTime.parse(dateTimeString);
    } catch (e) {
      print('❌ Error parsing date time: $dateTimeString, error: $e');
      return DateTime.now().add(const Duration(minutes: 5));
    }
  }

  String _formatValidationErrors(Map<String, dynamic> validationErrors) {
    final errorMessages = <String>[];

    validationErrors.forEach((field, errors) {
      if (errors is List) {
        for (var error in errors) {
          errorMessages.add('• $error');
        }
      } else if (errors is String) {
        errorMessages.add('• $errors');
      }
    });

    return errorMessages.isEmpty
        ? 'Validation failed'
        : 'Validation failed:\n${errorMessages.join('\n')}';
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
