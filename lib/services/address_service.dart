import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api.dart';
import '../models/address.dart';

class AddressService {
  static const String baseUrl = Api.baseUrl;

  // Get user's addresses
  static Future<List<Address>> getAddresses() async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List addresses = data['data'];
          return addresses.map((json) => Address.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching addresses: $e');
      return [];
    }
  }

  // Create new address
  static Future<Address?> createAddress(
    Map<String, dynamic> addressData,
  ) async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode(addressData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Address.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error creating address: $e');
      return null;
    }
  }

  // Update address
  static Future<Address?> updateAddress(
    int id,
    Map<String, dynamic> addressData,
  ) async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/addresses/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode(addressData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Address.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error updating address: $e');
      return null;
    }
  }

  // Delete address
  static Future<bool> deleteAddress(int id) async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/addresses/$id'),
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
      print('Error deleting address: $e');
      return false;
    }
  }

  // Set default address
  static Future<bool> setDefaultAddress(int id) async {
    try {
      final user = await Api.getCurrentUser();
      if (user == null || user.token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/addresses/$id/set-default'),
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
      print('Error setting default address: $e');
      return false;
    }
  }
}
