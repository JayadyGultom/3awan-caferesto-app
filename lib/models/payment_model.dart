class Pembayaran {
  final int id;
  final int pesananId;
  final String metode;
  final double jumlah;
  final String? tanggalBayar;

  Pembayaran({
    required this.id,
    required this.pesananId,
    required this.metode,
    required this.jumlah,
    this.tanggalBayar,
  });

  factory Pembayaran.fromJson(Map<String, dynamic> json) {
    return Pembayaran(
      id: json['id'] ?? 0,
      pesananId: json['pesanan_id'] ?? 0,
      metode: json['metode'] ?? '',
      jumlah: double.tryParse((json['jumlah'] ?? 0).toString()) ?? 0,
      tanggalBayar: json['tanggal_bayar'],
    );
  }
}




