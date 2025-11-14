class StokMenu {
  final int id;
  final int menuId;
  final int jumlah;
  final String tanggalStok; // format YYYY-MM-DD

  StokMenu({
    required this.id,
    required this.menuId,
    required this.jumlah,
    required this.tanggalStok,
  });

  factory StokMenu.fromJson(Map<String, dynamic> json) {
    return StokMenu(
      id: json['id'] ?? 0,
      menuId: json['menu_id'] ?? 0,
      jumlah: json['jumlah'] ?? 0,
      tanggalStok: json['tanggal_stok'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_id': menuId,
      'jumlah': jumlah,
      'tanggal_stok': tanggalStok,
    };
  }
}




