import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api.dart';
import '../models/coupon.dart';

class CouponService {
  static const String baseUrl = Api.baseUrl;

  // Get all active coupons
  static Future<List<Coupon>> getActiveCoupons() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/coupons'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List coupons = data['data'];
          return coupons.map((json) => Coupon.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching coupons: $e');
      return [];
    }
  }

  // Validate and apply coupon
  static Future<Map<String, dynamic>?> validateCoupon({
    required String code,
    required double subtotal,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/coupons/validate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code, 'subtotal': subtotal}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'coupon': Coupon.fromJson(data['data']['coupon']),
            'discount_amount': (data['data']['discount_amount'] as num)
                .toDouble(),
            'final_amount': (data['data']['final_amount'] as num).toDouble(),
          };
        }
      }

      // Return error message
      final data = jsonDecode(response.body);
      return {'error': data['message'] ?? 'Invalid coupon code'};
    } catch (e) {
      print('Error validating coupon: $e');
      return {'error': 'Failed to validate coupon'};
    }
  }
}
