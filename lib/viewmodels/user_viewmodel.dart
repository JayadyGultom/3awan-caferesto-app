import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class UserViewModel extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<Map<String, dynamic>> login(String email, String sandi) async {
    try {
      final response = await ApiService.loginUser(email, sandi);
      if (response["success"] == true) {
        _user = User.fromJson(response["data"]);
        notifyListeners();
      }
      return response;
    } catch (e) {
      debugPrint("Error login: $e");
      return {
        "success": false,
        "message": "Terjadi kesalahan: ${e.toString().replaceAll("Exception: ", "")}"
      };
    }
  }

  Future<Map<String, dynamic>> register(String email, String sandi) async {
    try {
      final response = await ApiService.registerUser(email, sandi);
      return response;
    } catch (e) {
      debugPrint("Error register: $e");
      return {
        "success": false,
        "message": "Terjadi kesalahan: ${e.toString().replaceAll("Exception: ", "")}"
      };
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
