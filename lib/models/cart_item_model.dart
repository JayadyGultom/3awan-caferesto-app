import 'menu_model.dart';

class CartItem {
  final Menu menu;
  int jumlah;

  CartItem({required this.menu, this.jumlah = 1});

  double get totalHarga => menu.harga * jumlah;
}
