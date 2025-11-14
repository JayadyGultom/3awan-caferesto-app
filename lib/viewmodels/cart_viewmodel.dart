import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/menu_model.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalHarga {
    return _items.fold(0, (sum, item) => sum + item.totalHarga);
  }

  void tambahKeKeranjang(Menu menu) {
    final index = _items.indexWhere((item) => item.menu.id == menu.id);

    if (index != -1) {
      _items[index].jumlah++;
    } else {
      _items.add(CartItem(menu: menu));
    }

    notifyListeners();
  }

  void kurangiJumlah(Menu menu) {
    final index = _items.indexWhere((item) => item.menu.id == menu.id);
    if (index != -1) {
      if (_items[index].jumlah > 1) {
        _items[index].jumlah--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void hapusItem(Menu menu) {
    _items.removeWhere((item) => item.menu.id == menu.id);
    notifyListeners();
  }

  void kosongkanKeranjang() {
    _items.clear();
    notifyListeners();
  }
}
