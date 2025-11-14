class Order {
  final int id;
  final int pelangganId;
  final int statusPembayaranId;
  final int statusPengirimanId;
  final double total;
  final String tanggalPesanan;
  final String? metodePembayaran;
  final double? jumlahPembayaran;

  Order({
    required this.id,
    required this.pelangganId,
    required this.statusPembayaranId,
    required this.statusPengirimanId,
    required this.total,
    required this.tanggalPesanan,
    this.metodePembayaran,
    this.jumlahPembayaran,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      pelangganId: json['pelanggan_id'] ?? 0,
      statusPembayaranId: json['status_pembayaran_id'] ?? 0,
      statusPengirimanId: json['status_pengiriman_id'] ?? 0,
      total: double.tryParse((json['total'] ?? 0).toString()) ?? 0,
      tanggalPesanan: json['tanggal_pesanan'] ?? '',
    );
  }

  Order copyWith({
    String? metodePembayaran,
    double? jumlahPembayaran,
  }) {
    return Order(
      id: id,
      pelangganId: pelangganId,
      statusPembayaranId: statusPembayaranId,
      statusPengirimanId: statusPengirimanId,
      total: total,
      tanggalPesanan: tanggalPesanan,
      metodePembayaran: metodePembayaran ?? this.metodePembayaran,
      jumlahPembayaran: jumlahPembayaran ?? this.jumlahPembayaran,
    );
  }
}

