import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_model.dart';
import '../viewmodels/cart_viewmodel.dart'; // ✅ penting untuk mengakses CartViewModel
import '../viewmodels/stock_viewmodel.dart';

class DetailMenuView extends StatelessWidget {
  final Menu menu;

  const DetailMenuView({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    final stockVM = Provider.of<StockViewModel>(context);
    final totalStok = stockVM.getStokUntukMenu(menu.id);
    final cart = Provider.of<CartViewModel>(context);
    int diKeranjang = 0;
    for (final it in cart.items) {
      if (it.menu.id == menu.id) {
        diKeranjang = it.jumlah;
        break;
      }
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(menu.nama),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar menu
            Hero(
              tag: "menu_${menu.id}",
              child: Image.network(
                menu.gambarUrl.isNotEmpty
                    ? menu.gambarUrl
                    : "https://via.placeholder.com/400x250?text=No+Image",
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // Informasi Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.nama,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Kategori: ${menu.kategori}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Harga: Rp ${menu.harga.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        "Stok: ",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        totalStok.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: totalStok > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Deskripsi:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    menu.deskripsi.isNotEmpty
                        ? menu.deskripsi
                        : "Tidak ada deskripsi untuk menu ini.",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 40),

                  // ✅ Tombol Tambah ke Keranjang
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (totalStok <= 0 || diKeranjang >= totalStok)
                          ? null
                          : () {
                        // Tambahkan menu ke keranjang
                        Provider.of<CartViewModel>(context, listen: false)
                            .tambahKeKeranjang(menu);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${menu.nama} berhasil ditambahkan ke keranjang 🛒",
                            ),
                            backgroundColor: Colors.red[700],
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text(
                        "Tambah ke Keranjang",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
