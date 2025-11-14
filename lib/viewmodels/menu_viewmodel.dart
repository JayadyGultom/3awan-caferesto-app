import 'package:flutter/material.dart';
import '../models/menu_model.dart';
import '../services/api_service.dart';

class MenuViewModel extends ChangeNotifier {
  List<Menu> _menus = [];
  bool _loading = false;
  String? _error;

  List<Menu> get menus => _menus;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchMenus() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _menus = await ApiService.getMenus();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll("Exception: ", "");
      debugPrint("Error fetchMenus: $e");
    }

    _loading = false;
    notifyListeners();
  }
}
