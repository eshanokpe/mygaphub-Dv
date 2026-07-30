// models/reminder_model.dart
// models/reminder_model.dart
class ReminderModel {
  final int id;
  final int userId;
  final String name;
  final int complete;
  final String? amount; // Keep as String since amount can be formatted
  final String date;
  final String time;
  final String alertDaysBefore;
  final String? note;
  final int sms; // Changed from String to int
  final int push;
  final int email;
  final String? extra;
  final String? alert;
  final int alerted;
  final String? archivedAt;
  final String? due;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int dueDays;
  final bool isOverdue;
  final String? alertDate;
  final String? reminderDatetime;
  final bool isPast;
  final String? alertHumanReadable;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.complete,
    this.amount,
    required this.date,
    required this.time,
    required this.alertDaysBefore,
    this.note,
    required this.sms, // Changed from String to int
    required this.push,
    required this.email,
    this.extra,
    this.alert,
    required this.alerted,
    this.archivedAt,
    this.due,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.dueDays,
    required this.isOverdue,
    this.alertDate,
    this.reminderDatetime,
    required this.isPast,
    this.alertHumanReadable,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      name: _parseString(json['name']),
      complete: _parseInt(json['complete']),
      amount: _parseString(json['amount']), // Use helper method
      date: _parseString(json['date']),
      time: _parseString(json['time']),
      alertDaysBefore: _parseString(json['alert_days_before']),
      note: _parseString(json['note']),
      sms: _parseInt(json['sms']), // Now parsing as int
      push: _parseInt(json['push']),
      email: _parseInt(json['email']),
      extra: _parseString(json['extra']),
      alert: _parseString(json['alert']),
      alerted: _parseInt(json['alerted']),
      archivedAt: _parseString(json['archived_at']),
      due: _parseString(json['due']),
      createdAt: _parseString(json['created_at']),
      updatedAt: _parseString(json['updated_at']),
      deletedAt: _parseString(json['deleted_at']),
      dueDays: _parseInt(json['due_days']),
      isOverdue: _parseBool(json['is_overdue']),
      alertDate: _parseString(json['alert_date']),
      reminderDatetime: _parseString(json['reminder_datetime']),
      isPast: _parseBool(json['is_past']),
      alertHumanReadable: _parseString(json['alert_human_readable']),
    );
  }

  // Helper methods to safely parse data
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.tryParse(value) ?? 0;
      } catch (e) {
        return 0;
      }
    }
    if (value is double) return value.toInt();
    return 0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }
}

class Actionplanmodel {
  final String date;
  final String note;

  Actionplanmodel({
    required this.date,
    required this.note,
  });
}
