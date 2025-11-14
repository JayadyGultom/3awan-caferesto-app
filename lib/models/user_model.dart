class User {
  final int id;
  final String email;
  final String peran;
  final String status;

  User({
    required this.id,
    required this.email,
    required this.peran,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      email: json["email"],
      peran: json["peran"],
      status: json["status"],
    );
  }
}
