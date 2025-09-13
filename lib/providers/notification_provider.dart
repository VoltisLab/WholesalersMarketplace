import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/token_service.dart';
import '../services/error_service.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      isRead: json['isRead'] ?? false,
      data: json['data'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadNotifications({String? type}) async {
    setLoading(true);
    setError(null);

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Please log in to view notifications');
      }

      final notificationsData = await NotificationService.getMyNotifications(
        token: token,
        type: type,
      );
      
      _notifications = notificationsData.map((json) => NotificationModel.fromJson(json)).toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      
      setLoading(false);
    } catch (e) {
      if (e is AppError) {
        setError(e.userMessage);
      } else {
        setError('Failed to load notifications: ${e.toString()}');
      }
      setLoading(false);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      await NotificationService.markNotificationRead(
        token: token,
        notificationId: notificationId,
      );

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          isRead: true,
          data: _notifications[index].data,
          createdAt: _notifications[index].createdAt,
        );
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      await NotificationService.markAllNotificationsRead(token);

      // Update local state
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        isRead: true,
        data: n.data,
        createdAt: n.createdAt,
      )).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> markNotificationRead(String notificationId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return;

      await NotificationService.markNotificationRead(
        token: token,
        notificationId: notificationId,
      );

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          isRead: true,
          data: _notifications[index].data,
          createdAt: _notifications[index].createdAt,
        );
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
}
