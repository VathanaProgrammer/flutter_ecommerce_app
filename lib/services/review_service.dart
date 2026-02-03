import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api.dart';
import '../models/review.dart';

class ReviewService {
  static const String baseUrl = Api.baseUrl;

  // Get product reviews
  static Future<List<Review>> getProductReviews(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId/reviews'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List reviews = data['data'];
          return reviews.map((json) => Review.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  // Create review
  static Future<Review?> createReview({
    required int productId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode({
          'product_id': productId,
          'rating': rating,
          'title': title,
          'comment': comment,
          'images': images,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Review.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error creating review: $e');
      return null;
    }
  }

  // Update review
  static Future<Review?> updateReview({
    required int reviewId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode({
          'rating': rating,
          'title': title,
          'comment': comment,
          'images': images,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Review.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error updating review: $e');
      return null;
    }
  }

  // Delete review
  static Future<bool> deleteReview(int reviewId) async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/reviews/$reviewId'),
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
      print('Error deleting review: $e');
      return false;
    }
  }

  // Vote review as helpful
  static Future<bool> voteHelpful(int reviewId, bool isHelpful) async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/reviews/$reviewId/vote-helpful'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode({'is_helpful': isHelpful}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error voting review: $e');
      return false;
    }
  }

  // Get user's reviews
  static Future<List<Review>> getUserReviews() async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/reviews/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List reviews = data['data'];
          return reviews.map((json) => Review.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching user reviews: $e');
      return [];
    }
  }
}
