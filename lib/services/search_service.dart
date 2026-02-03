import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api.dart';
import '../models/product.dart';

class SearchService {
  static const String baseUrl = Api.baseUrl;

  // Advanced product search
  static Future<Map<String, dynamic>> searchProducts({
    String? query,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    int? minRating,
    bool? isFeatured,
    bool? isRecommended,
    bool? inStock,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        if (query != null && query.isNotEmpty) 'q': query,
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
        if (minRating != null) 'min_rating': minRating.toString(),
        if (isFeatured != null) 'is_featured': isFeatured ? '1' : '0',
        if (isRecommended != null) 'is_recommended': isRecommended ? '1' : '0',
        if (inStock != null) 'in_stock': inStock ? '1' : '0',
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final uri = Uri.parse(
        '$baseUrl/search',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final productsData = data['data'];
          final List productList = productsData['data'] ?? productsData;

          return {
            'products': productList
                .map((json) => Product.fromJson(json))
                .toList(),
            'total': productsData['total'] ?? productList.length,
            'current_page': productsData['current_page'] ?? page,
            'last_page': productsData['last_page'] ?? 1,
          };
        }
      }
      return {
        'products': <Product>[],
        'total': 0,
        'current_page': 1,
        'last_page': 1,
      };
    } catch (e) {
      print('Error searching products: $e');
      return {
        'products': <Product>[],
        'total': 0,
        'current_page': 1,
        'last_page': 1,
      };
    }
  }

  // Get search suggestions
  static Future<List<Product>> getSearchSuggestions(String query) async {
    try {
      if (query.length < 2) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/search/suggestions?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List suggestions = data['data'];
          return suggestions.map((json) => Product.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching suggestions: $e');
      return [];
    }
  }

  // Get available filters
  static Future<Map<String, dynamic>> getFilters() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/filters'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return {};
    } catch (e) {
      print('Error fetching filters: $e');
      return {};
    }
  }
}
