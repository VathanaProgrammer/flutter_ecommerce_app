import 'package:http/http.dart' as http;
import 'dart:convert';
import './api.dart';

class CartService {
  static String get baseUrl => Api.baseUrl;

  static Future<Map<String, dynamic>> checkoutCash({
    required Map<String, dynamic> payloadSnapshot,
  }) async {
    final List<Map<String, dynamic>> output = [
      {'message': ''},
    ];
    bool isSuccess = false;

    try {
      final currentUser = await Api.getCurrentUser();

      if (currentUser == null) {
        output[0]['message'] = "You are not logged in. Please login first.";
        return {'isSuccess': false, 'output': output};
      }

      final body = {
        'user_id': int.parse(currentUser.id.toString()),
        'payload': payloadSnapshot,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/checkout/cash'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        output[0]['message'] = "Something went wrong!";
        return {'isSuccess': false, 'output': output};
      }

      final data = jsonDecode(response.body);

      isSuccess = data['success'] ?? true;
      output[0]['message'] = data['message'] ?? "Checkout successful";

      return {'isSuccess': isSuccess, 'output': output};
    } catch (e) {
      output[0]['message'] = 'Failed to process checkout: $e';
      return {'isSuccess': false, 'output': output};
    }
  }
}
