// models/notification_model.dart
import 'package:flutter/material.dart';

class NotificationModel {
  final int id;
  final int userId;
  final String? action;
  final String title;
  final String message;
  final bool seen;
  final String category;
  final String type;
  final Map<String, dynamic>? data;
  final DateTime receivedAt;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    this.action,
    required this.title,
    required this.message,
    required this.seen,
    required this.category,
    required this.type,
    this.data,
    required this.receivedAt,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for parsing API response
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      userId: json['user_id'] is String ? int.parse(json['user_id']) : json['user_id'] as int,
      action: json['action'],
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      seen: json['seen'] ?? false,
      category: json['category'] ?? 'info',
      type: json['type'] ?? 'general',
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
      receivedAt: DateTime.parse(json['received_at'] ?? json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Factory constructor for creating from Map (for local storage and FCM)
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    try {
      return NotificationModel(
        id: map['id'] is String ? int.parse(map['id']) : map['id'] as int,
        userId: map['user_id'] is String ? int.parse(map['user_id']) : map['user_id'] as int,
        action: map['action'],
        title: map['title'] ?? 'Notification',
        message: map['message'] ?? '',
        seen: map['seen'] ?? false,
        category: map['category'] ?? 'info',
        type: map['type'] ?? 'general',
        data: map['data'] is Map ? Map<String, dynamic>.from(map['data']) : null,
        receivedAt: DateTime.parse(map['received_at'] ?? map['created_at']),
        readAt: map['read_at'] != null ? DateTime.parse(map['read_at']) : null,
        createdAt: DateTime.parse(map['created_at']),
        updatedAt: DateTime.parse(map['updated_at']),
      );
    } catch (e) {
      // Fallback for background notifications or malformed data
      print('Error parsing notification from map: $e');
      
      // Get current timestamp for fallback
      final now = DateTime.now();
      final fallbackId = map['id'] is String ? 
          int.tryParse(map['id']) ?? DateTime.now().millisecondsSinceEpoch ~/ 1000 : 
          map['id'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      return NotificationModel(
        id: fallbackId as int,
        userId: 0, // Default user ID
        action: map['action'] ?? '',
        title: map['title'] ?? 'New Notification',
        message: map['body'] ?? map['message'] ?? '',
        seen: map['seen'] ?? map['isRead'] ?? false,
        category: map['category'] ?? 'info',
        type: map['type'] ?? 'general',
        data: map['data'] is Map ? Map<String, dynamic>.from(map['data']) : null,
        receivedAt: map['received_at'] != null ? 
            DateTime.parse(map['received_at']) : 
            map['timestamp'] != null ? 
                DateTime.parse(map['timestamp']) : now,
        readAt: map['read_at'] != null ? DateTime.parse(map['read_at']) : null,
        createdAt: map['created_at'] != null ? 
            DateTime.parse(map['created_at']) : now,
        updatedAt: now,
      );
    }
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'title': title,
      'message': message,
      'seen': seen,
      'category': category,
      'type': type,
      'data': data,
      'received_at': receivedAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert to Map for local storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'title': title,
      'message': message,
      'seen': seen,
      'category': category,
      'type': type,
      'data': data,
      'received_at': receivedAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper method to mark as read
  NotificationModel copyWith({
    int? id,
    int? userId,
    String? action,
    String? title,
    String? message,
    bool? seen,
    String? category,
    String? type,
    Map<String, dynamic>? data,
    DateTime? receivedAt,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      title: title ?? this.title,
      message: message ?? this.message,
      seen: seen ?? this.seen,
      category: category ?? this.category,
      type: type ?? this.type,
      data: data ?? this.data,
      receivedAt: receivedAt ?? this.receivedAt,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Mark as read
  NotificationModel markAsRead() {
    return copyWith(
      seen: true,
      readAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Mark as unread
  NotificationModel markAsUnread() {
    return copyWith(
      seen: false,
      readAt: null,
      updatedAt: DateTime.now(),
    );
  }

  // Check if notification has specific data
  bool hasDataKey(String key) {
    return data != null && data!.containsKey(key);
  }

  // Get data value with fallback
  dynamic getData(String key, {dynamic defaultValue}) {
    return data != null ? data![key] ?? defaultValue : defaultValue;
  }

  // Get notification color based on category
  Map<String, Color> get categoryColors {
    const colors = {
      'success': Color(0xFF10B981),
      'primary': Color(0xFF3B82F6),
      'info': Color(0xFF06B6D4),
      'warning': Color(0xFFF59E0B),
      'danger': Color(0xFFEF4444),
      'seed_report': Color(0xFF8B5CF6),
      'payment': Color(0xFF10B981),
      'order': Color(0xFF3B82F6),
      'chat': Color(0xFF8B5CF6),
      'general': Color(0xFF6B7280),
    };
    
    return {
      'color': colors[category] ?? const Color(0xFF6B7280),
      'lightColor': colors[category]?.withOpacity(0.1) ?? const Color(0xFFF3F4F6),
    };
  }

  // Get notification icon based on type
  String get icon {
    const icons = {
      'payment': '💳',
      'order': '📦',
      'seed_report': '📊',
      'chat': '💬',
      'reminder': '⏰',
      'news': '📰',
      'promotion': '🎁',
      'system': '⚙️',
    };
    
    return icons[type] ?? '📢';
  }

  // Check if notification is actionable
  bool get isActionable => action != null && action!.isNotEmpty;

  // Check if notification is recent (less than 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(receivedAt);
    return difference.inHours < 24;
  }

  // Get formatted time difference
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(receivedAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      return receivedAt.toString().substring(0, 10);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, seen: $seen, type: $type)';
  }
}

// Extension for List of NotificationModel
extension NotificationListExtension on List<NotificationModel> {
  // Get unread notifications
  List<NotificationModel> get unread => where((n) => !n.seen).toList();
  
  // Get read notifications
  List<NotificationModel> get read => where((n) => n.seen).toList();
  
  // Get notifications by type
  List<NotificationModel> byType(String type) => 
      where((n) => n.type == type).toList();
  
  // Get notifications by category
  List<NotificationModel> byCategory(String category) => 
      where((n) => n.category == category).toList();
  
  // Get recent notifications (last 7 days)
  List<NotificationModel> get recent => 
      where((n) => n.isRecent).toList();
  
  // Mark all as read
  List<NotificationModel> markAllAsRead() {
    return map((n) => n.markAsRead()).toList();
  }
  
  // Get grouped by date
  Map<String, List<NotificationModel>> groupByDate() {
    final Map<String, List<NotificationModel>> grouped = {};
    
    for (final notification in this) {
      final dateKey = _formatDate(notification.receivedAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notification);
    }
    
    return grouped;
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final notificationDate = DateTime(date.year, date.month, date.day);
    
    if (notificationDate == today) {
      return "Today";
    } else if (notificationDate == yesterday) {
      return "Yesterday";
    } else {
      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return "${date.day} ${monthNames[date.month - 1]}";
    }
  }
}