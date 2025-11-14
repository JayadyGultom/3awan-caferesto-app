class DetailPesanan {
  final int id;
  final int pesananId;
  final int menuId;
  final int jumlah;
  final double hargaSaatPesanan;

  DetailPesanan({
    required this.id,
    required this.pesananId,
    required this.menuId,
    required this.jumlah,
    required this.hargaSaatPesanan,
  });

  factory DetailPesanan.fromJson(Map<String, dynamic> json) {
    return DetailPesanan(
      id: json['id'] ?? 0,
      pesananId: json['pesanan_id'] ?? 0,
      menuId: json['menu_id'] ?? 0,
      jumlah: json['jumlah'] ?? 0,
      hargaSaatPesanan:
          double.tryParse((json['harga_saat_pesanan'] ?? 0).toString()) ?? 0,
    );
  }
}




