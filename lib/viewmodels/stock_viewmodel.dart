import 'package:flutter/foundation.dart';
import '../models/stok_menu_model.dart';
import '../services/api_service.dart';

class StockViewModel extends ChangeNotifier {
  bool _loading = false;
  List<StokMenu> _stok = [];
  final Map<int, int> _menuIdToTotalStok = {};

  bool get loading => _loading;
  Map<int, int> get totalStokPerMenu => _menuIdToTotalStok;

  Future<void> fetchStok() async {
    _loading = true;
    notifyListeners();
    try {
      _stok = await ApiService.getStokMenu();
      _menuIdToTotalStok
        ..clear()
        ..addAll(_hitungTotalStokPerMenu(_stok));
    } catch (e) {
      debugPrint('Gagal memuat stok: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Map<int, int> _hitungTotalStokPerMenu(List<StokMenu> list) {
    final Map<int, int> result = {};
    for (final s in list) {
      result[s.menuId] = (result[s.menuId] ?? 0) + s.jumlah;
    }
    return result;
    
  }

  int getStokUntukMenu(int menuId) {
    return totalStokPerMenu[menuId] ?? 0;
  }
}




