import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/menu_model.dart';
import '../models/order_model.dart';
import '../models/stok_menu_model.dart';
import '../models/detail_pesanan_model.dart';
import '../models/pelanggan_model.dart';
import '../models/status_model.dart';
import '../models/payment_model.dart';


class ApiService {
  static const String baseUrl =
      "https://3awan-caferesto-api-production-28ee.up.railway.app/";

  // 🔧 Fungsi umum untuk menampilkan error yang lebih informatif
  static String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (kIsWeb &&
        (errorString.contains('failed to fetch') ||
            errorString.contains('cors') ||
            errorString.contains('networkerror'))) {
      return "⚠️ Masalah CORS: Server API tidak mengizinkan request dari browser web.\n"
          "Silakan jalankan aplikasi di Android/iOS atau aktifkan CORS di backend Flask.";
    }

    if (errorString.contains('socketexception') ||
        errorString.contains('connection') ||
        errorString.contains('network')) {
      return "Tidak dapat terhubung ke server. Periksa koneksi internet kamu.";
    }

    if (errorString.contains('timeout')) {
      return "Server tidak merespons (timeout). Coba lagi nanti.";
    }

    return error.toString().replaceAll("Exception: ", "");
  }

  // 🔹 Ambil semua pelanggan
  static Future<List<Pelanggan>> getPelanggan() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/pelanggan"),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Pelanggan.fromJson(item)).toList();
      } else {
        throw Exception(
            "Gagal memuat data pelanggan. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  static Future<Map<String, dynamic>> tambahPelanggan({
    required int penggunaId,
    required String namaLengkap,
    String? telepon,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/pelanggan"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({
              "pengguna_id": penggunaId,
              "nama_lengkap": namaLengkap,
              "telepon": telepon,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message":
              "Gagal menambahkan pelanggan. Status: ${response.statusCode} Body: ${response.body}",
        };
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // 🔹 Ambil detail pesanan
  static Future<List<DetailPesanan>> getDetailPesanan() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/detail-pesanan"),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => DetailPesanan.fromJson(item)).toList();
      } else {
        throw Exception(
            "Gagal memuat detail pesanan. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // 🔹 Login Pengguna
  static Future<Map<String, dynamic>> loginUser(
      String email, String sandi) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/pengguna/login"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({
              "email": email,
              "sandi_hash": sandi,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 500) {
        // Handle 500 Internal Server Error
        String errorMessage = "Server mengalami masalah. Silakan coba lagi nanti.";
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody.containsKey("message")) {
            errorMessage = errorBody["message"];
          } else if (errorBody.containsKey("error")) {
            errorMessage = errorBody["error"];
          }
        } catch (_) {
          // Jika body tidak bisa di-parse, gunakan pesan default
        }
        return {
          "success": false,
          "message": errorMessage
        };
      } else {
        String errorMessage = "Gagal login. Silakan coba lagi.";
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody.containsKey("message")) {
            errorMessage = errorBody["message"];
          }
        } catch (_) {
          errorMessage = "Gagal login. Status: ${response.statusCode}";
        }
        return {
          "success": false,
          "message": errorMessage
        };
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // 🔹 Register Pengguna
  static Future<Map<String, dynamic>> registerUser(
      String email, String sandi) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/pengguna/register"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({
              "email": email,
              "sandi_hash": sandi,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message":
              "Gagal mendaftar. Status code: ${response.statusCode}\nBody: ${response.body}"
        };
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // 🔹 Ambil semua menu dari backend
  static Future<List<Menu>> getMenus() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/menu"),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Menu.fromJson(item)).toList();
      } else {
        throw Exception(
            "Gagal memuat menu. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // 🔹 Kirim Pesanan (Checkout) → mengembalikan { id }
  static Future<Map<String, dynamic>> kirimPesanan(
      Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/pesanan"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message":
              "Gagal mengirim pesanan. Status: ${response.statusCode}\nBody: ${response.body}"
        };
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // 🔹 Tambah Detail Pesanan
  static Future<Map<String, dynamic>> tambahDetailPesanan({
    required int pesananId,
    required int menuId,
    required int jumlah,
    required double hargaSaatPesanan,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/detail-pesanan"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({
              "pesanan_id": pesananId,
              "menu_id": menuId,
              "jumlah": jumlah,
              "harga_saat_pesanan": hargaSaatPesanan,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message":
              "Gagal menambah detail pesanan. Status: ${response.statusCode} Body: ${response.body}",
        };
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // 🔹 Ambil status pembayaran & pengiriman
  static Future<List<StatusRef>> getStatusPembayaran() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/status-pembayaran"),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => StatusRef.fromJson(item)).toList();
      } else {
        throw Exception(
            "Gagal memuat status pembayaran. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  static Future<List<StatusRef>> getStatusPengiriman() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/status-pengiriman"),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => StatusRef.fromJson(item)).toList();
      } else {
        throw Exception(
            "Gagal memuat status pengiriman. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // 🔹 Tambah pembayaran
  static Future<Map<String, dynamic>> tambahPembayaran({
    required int pesananId,
    required String metode,
    required double jumlah,
    String? tanggalBayar,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/pembayaran"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({
              "pesanan_id": pesananId,
              "metode": metode,
              "jumlah": jumlah,
              "tanggal_bayar": tanggalBayar,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 500) {
        // Handle 500 Internal Server Error
        String errorMessage = "Server mengalami masalah saat menyimpan pembayaran.";
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody.containsKey("message")) {
            errorMessage = errorBody["message"];
          } else if (errorBody.containsKey("error")) {
            errorMessage = errorBody["error"];
          }
        } catch (_) {
          // Jika body tidak bisa di-parse, gunakan pesan default
        }
        return {
          "success": false,
          "message": errorMessage
        };
      } else {
        return {
          "success": false,
          "message":
              "Gagal menambah pembayaran. Status: ${response.statusCode} Body: ${response.body}",
        };
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  static Future<List<Pembayaran>> getPembayaran() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/pembayaran"),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Pembayaran.fromJson(item)).toList();
      } else if (response.statusCode == 500) {
        // Jika server error, return empty list daripada throw exception
        debugPrint("⚠️ Server error saat fetch pembayaran, mengembalikan list kosong");
        return [];
      } else {
        throw Exception(
            "Gagal memuat pembayaran. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // Jika timeout atau network error, return empty list
      if (e.toString().toLowerCase().contains('timeout') ||
          e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connection')) {
        debugPrint("⚠️ Network error saat fetch pembayaran: $e");
        return [];
      }
      throw Exception(_getErrorMessage(e));
    }
  }

  // 🔹 Ambil semua stok menu
  static Future<List<StokMenu>> getStokMenu() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/stok-menu"),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => StokMenu.fromJson(item)).toList();
      } else {
        throw Exception(
            "Gagal memuat stok menu. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // 🔹 Tambah stok menu (gunakan jumlah negatif untuk mengurangi stok)
  static Future<Map<String, dynamic>> tambahStokMenu({
    required int menuId,
    required int jumlah,
    required String tanggalStok, // YYYY-MM-DD
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/stok-menu"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({
              "menu_id": menuId,
              "jumlah": jumlah, // Bisa positif (tambah) atau negatif (kurangi)
              "tanggal_stok": tanggalStok,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        // Pastikan response memiliki format yang konsisten
        if (result is Map && result.containsKey("id")) {
          return {
            "success": true,
            "message": jumlah < 0 
                ? "Stok berhasil dikurangi sebanyak ${jumlah.abs()}"
                : "Stok berhasil ditambahkan sebanyak $jumlah",
            "data": result,
          };
        }
        return {
          "success": true,
          "message": "Stok berhasil diperbarui",
          "data": result,
        };
      } else {
        return {
          "success": false,
          "message":
              "Gagal memperbarui stok. Status: ${response.statusCode} Body: ${response.body}",
        };
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // 🔹 Tambah alamat pelanggan
  static Future<Map<String, dynamic>> tambahAlamatPelanggan({
    required int pelangganId,
    required String alamat,
    bool utama = false,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/alamat"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({
              "pelanggan_id": pelangganId,
              "alamat": alamat,
              "utama": utama,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 500) {
        // Handle 500 Internal Server Error
        String errorMessage = "Server mengalami masalah saat menyimpan alamat.";
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody.containsKey("message")) {
            errorMessage = errorBody["message"];
          } else if (errorBody.containsKey("error")) {
            errorMessage = errorBody["error"];
          }
        } catch (_) {
          // Jika body tidak bisa di-parse, gunakan pesan default
        }
        return {
          "success": false,
          "message": errorMessage
        };
      } else {
        return {
          "success": false,
          "message":
              "Gagal menambahkan alamat. Status: ${response.statusCode} Body: ${response.body}",
        };
      }
    } catch (e) {
      // Untuk timeout atau network error, return success:false dengan pesan yang jelas
      final errorMsg = _getErrorMessage(e);
      return {
        "success": false,
        "message": errorMsg,
      };
    }
  }

  static Future<List<Order>> getPesanan() async {
  try {
    final response = await http.get(
      Uri.parse("$baseUrl/pesanan"),
      headers: {"Accept": "application/json"},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception("Gagal memuat pesanan. Status: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception(_getErrorMessage(e));
  }
}

}
