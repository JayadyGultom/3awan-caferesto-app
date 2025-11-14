import 'package:flutter/foundation.dart';
import '../models/pelanggan_model.dart';
import '../services/api_service.dart';

class CustomerViewModel extends ChangeNotifier {
  Pelanggan? _pelanggan;
  bool _loading = false;

  Pelanggan? get pelanggan => _pelanggan;
  bool get loading => _loading;

  Future<void> loadForPengguna(int penggunaId) async {
    _loading = true;
    notifyListeners();
    try {
      final semua = await ApiService.getPelanggan();
      _pelanggan = null;
      for (final p in semua) {
        if (p.penggunaId == penggunaId) {
          _pelanggan = p;
          break;
        }
      }
    } catch (e) {
      debugPrint('Gagal memuat pelanggan: $e');
      _pelanggan = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Pelanggan?> createIfMissing({
    required int penggunaId,
    required String namaLengkap,
    String? telepon,
  }) async {
    if (_pelanggan != null) return _pelanggan;
    try {
      final response = await ApiService.tambahPelanggan(
        penggunaId: penggunaId,
        namaLengkap: namaLengkap,
        telepon: telepon,
      );
      if (response['id'] != null) {
        _pelanggan = Pelanggan(
          id: response['id'],
          penggunaId: penggunaId,
          namaLengkap: namaLengkap,
          telepon: telepon,
        );
        notifyListeners();
        return _pelanggan;
      }
    } catch (e) {
      debugPrint('Gagal membuat pelanggan: $e');
    }
    return null;
  }

  void clear() {
    _pelanggan = null;
    notifyListeners();
  }
}


