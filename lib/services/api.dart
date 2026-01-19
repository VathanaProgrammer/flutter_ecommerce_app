import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart'; // Make sure this path is correct

class Api {
  static const String baseUrl = 'https://learner-teach.online/api';
  static const String userKey = 'current_user';

  // Login
  static Future<User?> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true && body['user'] != null) {
          // Build a full user map including token
          final userMap = Map<String, dynamic>.from(body['user']);
          userMap['token'] = body['token'];

          final user = User.fromJson(userMap);

          // Save user locally
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(userKey, jsonEncode(user.toJson()));

          return user;
        }

        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Get saved user
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(userKey);
    if (jsonString != null) {
      final jsonMap = jsonDecode(jsonString);
      return User.fromJson(Map<String, dynamic>.from(jsonMap));
    }
    return null;
  }

  // Logout / clear user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
  }

  static Future<Map<String, dynamic>> getHomeData({
    String? category,
    String? search,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/home?category=${category ?? ""}&search=${search ?? ""}',
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load home data');
    }
  }
}
