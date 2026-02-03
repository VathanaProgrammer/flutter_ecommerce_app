import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String username, String password) async {
    final user = await Api.login(username, password);

    if (user != null) {
      _user = user;
      notifyListeners();
      return true;
    }

    return false;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return false;

    final updatedUser = await Api.updateUserProfile(_user!.id, data);

    if (updatedUser != null) {
      _user = updatedUser;
      notifyListeners();
      return true;
    }

    return false;
  }
}
