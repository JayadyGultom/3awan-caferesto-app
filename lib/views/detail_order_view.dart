import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../models/detail_pesanan_model.dart';
import '../models/menu_model.dart';
import '../viewmodels/menu_viewmodel.dart';
import '../services/api_service.dart';
import '../viewmodels/status_viewmodel.dart';

class DetailOrderView extends StatefulWidget {
  final Order order;

  const DetailOrderView({super.key, required this.order});

  @override
  State<DetailOrderView> createState() => _DetailOrderViewState();
}

class _DetailWithMenu {
  final DetailPesanan detail;
  final Menu? menu;

  _DetailWithMenu({required this.detail, required this.menu});
}

class _DetailOrderViewState extends State<DetailOrderView> {
  late Future<List<_DetailWithMenu>> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  Future<List<_DetailWithMenu>> _loadDetail() async {
    final menuVM = Provider.of<MenuViewModel>(context, listen: false);
    if (menuVM.menus.isEmpty && !menuVM.loading) {
      await menuVM.fetchMenus();
    }

    final List<DetailPesanan> allDetails = await ApiService.getDetailPesanan();
    final filtered =
        allDetails.where((d) => d.pesananId == widget.order.id).toList();

    final Map<int, Menu> menuMap = {
      for (final menu in menuVM.menus) menu.id: menu,
    };

    return filtered
        .map((detail) => _DetailWithMenu(
              detail: detail,
              menu: menuMap[detail.menuId],
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final statusVM = Provider.of<StatusViewModel>(context);
    final statusPembayaran =
        statusVM.namaStatusPembayaran(order.statusPembayaranId);
    final statusPengiriman =
        statusVM.namaStatusPengiriman(order.statusPengirimanId);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text("Pesanan #${order.id}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📅 Informasi Pesanan
            Card(
              color: Colors.amber[50],
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.amber[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Text(
                          "Tanggal: ${order.tanggalPesanan}",
                          style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.payment, size: 16, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Text(
                          "Metode Pembayaran: ${order.metodePembayaran ?? '-'}",
                          style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Text(
                          "Status Pembayaran: $statusPembayaran",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.local_shipping, size: 16, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Text(
                          "Status Pengiriman: $statusPengiriman",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Text(
              "Daftar Item:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 10),

            // 🧾 Daftar Item
            Expanded(
              child: FutureBuilder<List<_DetailWithMenu>>(
                future: _detailFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Gagal memuat detail pesanan: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final details = snapshot.data ?? [];
                  if (details.isEmpty) {
                    return const Center(
                      child: Text('Belum ada detail item untuk pesanan ini.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: details.length,
                    itemBuilder: (context, index) {
                      final detail = details[index];
                      final menuNama = detail.menu?.nama ?? 'Menu #${detail.detail.menuId}';
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Icon(
                            Icons.fastfood,
                            color: Colors.red[700],
                          ),
                          title: Text(
                            menuNama,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Jumlah: ${detail.detail.jumlah}"),
                          trailing: Text(
                            "Rp ${detail.detail.hargaSaatPesanan.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // 💰 Total Harga
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Pembayaran:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Text(
                    "Rp ${order.total.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
