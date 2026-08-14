class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final String role; // "ADMIN" | "CUSTOMER"

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"] ?? "",
    email: json["email"] ?? "",
    phone: json["phone"],
    profileImageUrl: json["profileImageUrl"],
    role: json["role"] ?? "CUSTOMER",
  );
}