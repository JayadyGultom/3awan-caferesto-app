class StatusRef {
  final int id;
  final String namaStatus;

  StatusRef({required this.id, required this.namaStatus});

  factory StatusRef.fromJson(Map<String, dynamic> json) {
    return StatusRef(
      id: json['id'] ?? 0,
      namaStatus: json['nama_status'] ?? '',
    );
  }
}




