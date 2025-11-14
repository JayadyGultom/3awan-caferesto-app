import 'package:flutter/foundation.dart';
import '../models/status_model.dart';
import '../services/api_service.dart';

class StatusViewModel extends ChangeNotifier {
  List<StatusRef> _statusPembayaran = [];
  List<StatusRef> _statusPengiriman = [];
  bool _loading = false;

  List<StatusRef> get statusPembayaran => _statusPembayaran;
  List<StatusRef> get statusPengiriman => _statusPengiriman;
  bool get loading => _loading;

  StatusRef? get defaultStatusPembayaran =>
      _statusPembayaran.isNotEmpty ? _statusPembayaran.first : null;

  StatusRef? get defaultStatusPengiriman =>
      _statusPengiriman.isNotEmpty ? _statusPengiriman.first : null;

  Future<void> fetchAll() async {
    _loading = true;
    notifyListeners();
    try {
      final pembayaran = await ApiService.getStatusPembayaran();
      final pengiriman = await ApiService.getStatusPengiriman();
      _statusPembayaran = pembayaran;
      _statusPengiriman = pengiriman;
    } catch (e) {
      debugPrint('Gagal memuat status referensi: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String namaStatusPembayaran(int id) {
    for (final s in _statusPembayaran) {
      if (s.id == id) return s.namaStatus;
    }
    return 'Status #$id';
  }

  String namaStatusPengiriman(int id) {
    for (final s in _statusPengiriman) {
      if (s.id == id) return s.namaStatus;
    }
    return 'Status #$id';
  }
}


