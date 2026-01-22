import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import './api.dart';

class FavoriteService {
  static const String baseUrl = Api.baseUrl;

  /// Get the current logged-in user
  Future<User> _getUser() async {
    final user = await Api.getCurrentUser();
    if (user == null) throw Exception('No logged-in user found');
    return user;
  }

  /// Fetch user's favorite product IDs
  Future<List<int>> getFavorites() async {
    final currentUser = await _getUser();
    final url = Uri.parse('$baseUrl/favorites?user_id=${currentUser.id}');
    final response = await http.get(url, headers: _headers(currentUser));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<int>.from(data['favorite_product_ids'] ?? []);
    } else {
      throw Exception('Failed to fetch favorites');
    }
  }

  /// Add product to favorites
  Future<void> addFavorite(int productId) async {
    final currentUser = await _getUser();
    final url = Uri.parse('$baseUrl/favorites/add');
    final response = await http.post(
      url,
      headers: _headers(currentUser),
      body: jsonEncode({
        'user_id': currentUser.id,
        'product_id': productId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add favorite');
    }
  }

  /// Remove product from favorites
  Future<void> removeFavorite(int productId) async {
    final currentUser = await _getUser();
    final url = Uri.parse('$baseUrl/favorites/remove');
    final response = await http.post(
      url,
      headers: _headers(currentUser),
      body: jsonEncode({
        'user_id': currentUser.id,
        'product_id': productId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove favorite');
    }
  }

  /// Toggle favorite
  Future<void> toggleFavorite(int productId, {required bool isFavorite}) async {
    if (isFavorite) {
      await removeFavorite(productId);
    } else {
      await addFavorite(productId);
    }
  }

  /// Common headers
  Map<String, String> _headers(User currentUser) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${currentUser.token}',
    };
  }
}
