import 'package:http/http.dart' as http;
import 'dart:convert';
import './api.dart';
import '../models/ProductDetail.dart';

class ProductService {
  static String get baseUrl => Api.baseUrl;

  // Fetch product details with variants and attributes
  static Future<ProductDetail> getProductDetail(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductDetail.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }
}