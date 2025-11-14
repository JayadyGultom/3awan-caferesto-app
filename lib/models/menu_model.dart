class Menu {
  final int id;
  final String nama;
  final String kategori;
  final double harga;
  final String deskripsi;
  final String gambarUrl;

  Menu({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.deskripsi,
    required this.gambarUrl,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      kategori: json['kategori'] ?? '',
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      deskripsi: json['deskripsi'] ?? '',
      gambarUrl: json['gambar_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nama": nama,
      "kategori": kategori,
      "harga": harga,
      "deskripsi": deskripsi,
      "gambar_url": gambarUrl,
    };
  }
}
