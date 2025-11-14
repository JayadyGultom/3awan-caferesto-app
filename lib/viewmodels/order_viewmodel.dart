import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/payment_model.dart';
import '../services/api_service.dart';

class OrderViewModel extends ChangeNotifier {
  List<Order> _orders = [];
  bool _loading = false;
  bool _creatingOrder = false;

  List<Order> get orders => _orders;
  bool get loading => _loading;
  bool get creatingOrder => _creatingOrder;

  Future<void> fetchOrders(int pelangganId) async {
    _loading = true;
    notifyListeners();

    try {
      final data = await ApiService.getPesanan();
      final payments = await ApiService.getPembayaran();
      final Map<int, Pembayaran> paymentMap = {
        for (final p in payments) p.pesananId: p,
      };

      // Filter hanya pesanan milik pelanggan login
      _orders = data
          .where((o) => o.pelangganId == pelangganId)
          .map((order) {
        final pay = paymentMap[order.id];
        return order.copyWith(
          metodePembayaran: pay?.metode,
          jumlahPembayaran: pay?.jumlah,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error fetch orders: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> pesananData) async {
    _creatingOrder = true;
    notifyListeners();

    try {
      final response = await ApiService.kirimPesanan(pesananData);
      return response;
    } catch (e) {
      debugPrint("Error create order: $e");
      return {
        "success": false,
        "message": "Terjadi kesalahan: ${e.toString().replaceAll("Exception: ", "")}"
      };
    } finally {
      _creatingOrder = false;
      notifyListeners();
    }
  }
}
