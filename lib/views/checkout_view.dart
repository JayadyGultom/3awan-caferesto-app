import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/order_viewmodel.dart';
import '../viewmodels/stock_viewmodel.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../viewmodels/status_viewmodel.dart';
import '../services/api_service.dart';
import 'home_view.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  String _selectedPayment = "Tunai";
  final TextEditingController _alamatController = TextEditingController();

  @override
  void dispose() {
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _buatPesanan() async {
    final cart = Provider.of<CartViewModel>(context, listen: false);
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);
    final stockVM = Provider.of<StockViewModel>(context, listen: false);
    final customerVM = Provider.of<CustomerViewModel>(context, listen: false);
    final statusVM = Provider.of<StatusViewModel>(context, listen: false);

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Keranjang masih kosong!")),
      );
      return;
    }

    if (userVM.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan login terlebih dahulu!")),
      );
      return;
    }

    try {
      // Validasi stok sebelum membuat pesanan
      final List<String> gagal = [];
      for (final i in cart.items) {
        final stok = stockVM.getStokUntukMenu(i.menu.id);
        if (i.jumlah > stok) {
          gagal.add("${i.menu.nama} (stok: $stok, diminta: ${i.jumlah})");
        }
      }
      if (gagal.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Stok tidak mencukupi untuk:\n- ${gagal.join("\n- ")}",
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
      final userId = userVM.user!.id;

      if (customerVM.pelanggan == null) {
        await customerVM.loadForPengguna(userId);
        if (!mounted) return;
      }

      final pelanggan = customerVM.pelanggan;
      if (pelanggan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Data pelanggan belum tersedia. Lengkapi profil terlebih dahulu."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validasi alamat
      if (_alamatController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Silakan masukkan alamat pengiriman"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Simpan alamat ke database (opsional, tidak menghentikan proses checkout)
      try {
        final alamatResult = await ApiService.tambahAlamatPelanggan(
          pelangganId: pelanggan.id,
          alamat: _alamatController.text.trim(),
          utama: true,
        );
        
        if (alamatResult["success"] == false) {
          debugPrint('⚠️ Gagal menyimpan alamat: ${alamatResult["message"]}');
          // Lanjutkan proses checkout meskipun alamat gagal disimpan
          // Alamat masih bisa digunakan untuk pesanan ini
        } else {
          debugPrint('✅ Alamat berhasil disimpan');
        }
      } catch (e) {
        debugPrint('⚠️ Error saat menyimpan alamat: $e');
        // Lanjutkan proses checkout meskipun alamat gagal disimpan
      }

      // Pastikan status referensi tersedia
      if (statusVM.statusPembayaran.isEmpty ||
          statusVM.statusPengiriman.isEmpty) {
        await statusVM.fetchAll();
        if (!mounted) return;
      }

      final statusPembayaranId =
          statusVM.defaultStatusPembayaran?.id ?? 1; // fallback
      final statusPengirimanId =
          statusVM.defaultStatusPengiriman?.id ?? 1; // fallback
      final now = DateTime.now();
      final tanggalPesanan = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      // Format data pesanan sesuai dengan API backend
      final pesanan = {
        "pelanggan_id": pelanggan.id,
        "status_pembayaran_id": statusPembayaranId,
        "status_pengiriman_id": statusPengirimanId,
        "total": cart.totalHarga,
        "tanggal_pesanan": tanggalPesanan,
      };

      final response = await orderVM.createOrder(pesanan);

      if (!mounted) return;

      if (response["id"] != null || response["success"] == true) {
        final pesananId = response["id"] ?? 0;
        // Buat detail pesanan untuk tiap item
        for (final i in cart.items) {
          try {
            await ApiService.tambahDetailPesanan(
              pesananId: pesananId,
              menuId: i.menu.id,
              jumlah: i.jumlah,
              hargaSaatPesanan: i.menu.harga,
            );
          } catch (e) {
            debugPrint('Gagal menambah detail pesanan: $e');
          }
        }
        // Simpan data pembayaran
        try {
          final pembayaranResult = await ApiService.tambahPembayaran(
            pesananId: pesananId,
            metode: _selectedPayment,
            jumlah: cart.totalHarga,
            tanggalBayar: null,
          );
          
          if (pembayaranResult["success"] == false) {
            debugPrint('⚠️ Gagal menyimpan pembayaran: ${pembayaranResult["message"]}');
            // Tampilkan warning tapi lanjutkan proses
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Pesanan berhasil dibuat, tapi ada masalah menyimpan data pembayaran.\n"
                  "Silakan hubungi admin untuk konfirmasi pembayaran.",
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          } else {
            debugPrint('✅ Data pembayaran berhasil disimpan');
          }
        } catch (e) {
          debugPrint('⚠️ Error saat menyimpan pembayaran: $e');
          // Tampilkan warning tapi lanjutkan proses
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Pesanan berhasil dibuat, tapi ada masalah menyimpan data pembayaran.\n"
                "Silakan hubungi admin untuk konfirmasi pembayaran.",
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        
        // ✅ Kurangi stok untuk setiap item yang dipesan dengan membuat entri stok negatif
        final tgl = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        final List<String> stokGagal = [];
        
        for (final i in cart.items) {
          try {
            final result = await ApiService.tambahStokMenu(
              menuId: i.menu.id,
              jumlah: -i.jumlah, // Jumlah negatif untuk mengurangi stok
              tanggalStok: tgl,
            );
            
            // Cek apakah berhasil
            if (result["success"] == false) {
              stokGagal.add("${i.menu.nama}: ${result["message"] ?? "Gagal mengurangi stok"}");
              debugPrint('Gagal mengurangi stok ${i.menu.nama}: ${result["message"]}');
            } else {
              debugPrint('✅ Stok ${i.menu.nama} berhasil dikurangi sebanyak ${i.jumlah}');
            }
          } catch (e) {
            stokGagal.add("${i.menu.nama}: ${e.toString()}");
            debugPrint('❌ Error mengurangi stok menu ${i.menu.id} (${i.menu.nama}): $e');
          }
        }
        
        // Tampilkan warning jika ada stok yang gagal dikurangi
        if (stokGagal.isNotEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Pesanan berhasil dibuat, tapi ada masalah mengurangi stok:\n${stokGagal.join("\n")}",
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        
        // Refresh stok setelah pengurangan
        await stockVM.fetchStok();
        if (!mounted) return;
        // Refresh order history setelah pesanan berhasil dibuat
        await orderVM.fetchOrders(pelanggan.id);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pesanan berhasil dibuat ✅"),
            backgroundColor: Colors.green,
          ),
        );
        
        // Kosongkan keranjang
        cart.kosongkanKeranjang();
        
        // Kembali ke home dengan email user yang benar
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomeView(email: userVM.user!.email),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Gagal membuat pesanan"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartViewModel>(context);
    final orderVM = Provider.of<OrderViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daftar Item - Card lebih kecil
            const Text(
              "Item Pesanan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...cart.items.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.menu.gambarUrl.isNotEmpty
                              ? item.menu.gambarUrl
                              : "https://via.placeholder.com/60x60?text=No+Image",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported, size: 24),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.menu.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rp ${item.menu.harga.toStringAsFixed(0)} x ${item.jumlah}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Rp ${(item.menu.harga * item.jumlah).toStringAsFixed(0)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Input Alamat
            const Text(
              "Alamat Pengiriman",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _alamatController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Masukkan alamat lengkap pengiriman",
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Metode Pembayaran
            const Text(
              "Metode Pembayaran",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedPayment,
              items: const [
                DropdownMenuItem(value: "Tunai", child: Text("Tunai di tempat")),
                DropdownMenuItem(value: "Transfer", child: Text("Transfer Bank")),
                DropdownMenuItem(value: "E-Wallet", child: Text("E-Wallet")),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedPayment = value);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.payment),
              ),
            ),
            const SizedBox(height: 24),

            // Total Harga
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Pembayaran:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Rp ${cart.totalHarga.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Buat Pesanan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: orderVM.creatingOrder ? null : _buatPesanan,
                icon: orderVM.creatingOrder
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.payment),
                label: Text(
                  orderVM.creatingOrder ? "Memproses..." : "Buat Pesanan Sekarang",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
