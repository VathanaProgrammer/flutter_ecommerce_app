import 'package:http/http.dart' as http;
import 'dart:convert';
import './api.dart';

class QRPaymentService {
  static String get baseUrl => Api.baseUrl;

  /// Create a PaymentIntent and generate QR
  static Future<Map<String, dynamic>> createPaymentIntent({
    required Map<String, dynamic> payloadSnapshot,
  }) async {
    final currentUser = await Api.getCurrentUser();
    if (currentUser == null) throw Exception('User not logged in');

    final body = {'user_id': currentUser.id, 'payload': payloadSnapshot};

    final response = await http.post(
      Uri.parse('$baseUrl/create-qr'),headers: {'Content-Type': 'application/json'}, body: jsonEncode(body),);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);

    return {
      'tran_id': data['tran_id'],
      'qr_image': data['qr_image'],
      'scan_url': data['scan_url'],
      'payment_intent_id': data['payment_intent_id'],
    };
  }

  // Check payment status remains the same
  static Future<bool> checkPaymentStatus(String tranId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment-intents/check/$tranId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Error checking payment: $e');
      return false;
    }
  }

  static Future<bool> autoPayAfter2Sec(String tranId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auto_pay/$tranId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      print('Filed after auto pay1: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Filed after auto pay: $e');
      return false;
    }
  }
}
