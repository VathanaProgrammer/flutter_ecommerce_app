import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api.dart';
import '../models/notification.dart';

class NotificationService {
  static const String baseUrl = Api.baseUrl;

  // Get notifications
  static Future<List<AppNotification>> getNotifications({
    bool unreadOnly = false,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        throw Exception('User not authenticated');
      }

      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (unreadOnly) 'unread_only': 'true',
      };

      final uri = Uri.parse(
        '$baseUrl/notifications',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List notifications = data['data']['data'] ?? data['data'];
          return notifications
              .map((json) => AppNotification.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // Get unread count
  static Future<int> getUnreadCount() async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        return 0;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data']['count'] ?? 0;
        }
      }
      return 0;
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  // Mark notification as read
  static Future<bool> markAsRead(int id) async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/$id/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all as read
  static Future<bool> markAllAsRead() async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error marking all as read: $e');
      return false;
    }
  }

  // Delete notification
  static Future<bool> deleteNotification(int id) async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Clear all notifications
  static Future<bool> clearAll() async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error clearing notifications: $e');
      return false;
    }
  }
}
