import 'package:http/http.dart' as http;
import 'dart:convert';
import './api.dart';

class OrdersService {
  static String get baseUrl => Api.baseUrl;

  /// Get all user orders
  static Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final currentUser = await Api.getCurrentUser();
      if (currentUser == null) throw Exception('User not logged in');

      final response = await http.get(
        Uri.parse('$baseUrl/user/orders?user_id=${currentUser.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['orders']);
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  /// Get single order details
  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final currentUser = await Api.getCurrentUser();
      if (currentUser == null) throw Exception('User not logged in');

      final response = await http.get(
        Uri.parse('$baseUrl/user/orders/$orderId?user_id=${currentUser.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['order'];
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      throw Exception('Error fetching order details: $e');
    }
  }
}