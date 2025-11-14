import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/order_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../views/detail_order_view.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../viewmodels/status_viewmodel.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadOrders);
  }

  Future<void> _loadOrders() async {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    final customerVM = Provider.of<CustomerViewModel>(context, listen: false);
    if (userVM.user != null) {
      await customerVM.loadForPengguna(userVM.user!.id);
      if (!mounted) return;
      final pelanggan = customerVM.pelanggan;
      if (pelanggan != null) {
        await Provider.of<OrderViewModel>(context, listen: false)
            .fetchOrders(pelanggan.id);
        if (!mounted) return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderVM = Provider.of<OrderViewModel>(context);
    final statusVM = Provider.of<StatusViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Riwayat Pesanan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: () {
              _loadOrders();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadOrders();
        },
        child: orderVM.loading && orderVM.orders.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : orderVM.orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada riwayat pesanan 😅",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: orderVM.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderVM.orders[index];
                      final bayarNama = statusVM
                          .namaStatusPembayaran(order.statusPembayaranId)
                          .toLowerCase();
                      Color statusColor = Colors.grey;
                      if (bayarNama.contains('lunas') ||
                          bayarNama.contains('selesai') ||
                          bayarNama.contains('konfirmasi')) {
                        statusColor = Colors.green;
                      } else if (bayarNama.contains('belum') ||
                          bayarNama.contains('menunggu')) {
                        statusColor = Colors.orange;
                      } else if (bayarNama.contains('batal')) {
                        statusColor = Colors.red;
                      }
                      final statusPengiriman =
                          statusVM.namaStatusPengiriman(order.statusPengirimanId);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber[100],
                            child: Icon(
                              Icons.receipt,
                              color: Colors.red[700],
                            ),
                          ),
                          title: Text(
                            "Pesanan #${order.id}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("Tanggal: ${order.tanggalPesanan}"),
                              Text("Metode: ${order.metodePembayaran ?? '-'}"),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  'Pembayaran: ${statusVM.namaStatusPembayaran(order.statusPembayaranId)}\nPengiriman: $statusPengiriman',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Total: Rp ${order.total.toStringAsFixed(0)}",
                                style: TextStyle(
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailOrderView(order: order),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
