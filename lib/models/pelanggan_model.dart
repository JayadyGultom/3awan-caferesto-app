class Pelanggan {
  final int id;
  final int penggunaId;
  final String namaLengkap;
  final String? telepon;

  Pelanggan({
    required this.id,
    required this.penggunaId,
    required this.namaLengkap,
    this.telepon,
  });

  factory Pelanggan.fromJson(Map<String, dynamic> json) {
    return Pelanggan(
      id: json['id'] ?? 0,
      penggunaId: json['pengguna_id'] ?? 0,
      namaLengkap: json['nama_lengkap'] ?? '',
      telepon: json['telepon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pengguna_id': penggunaId,
      'nama_lengkap': namaLengkap,
      'telepon': telepon,
    };
  }
}




