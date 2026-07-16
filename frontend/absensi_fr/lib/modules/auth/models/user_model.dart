class UserModel {
  final int id;
  final String username;
  final String email;
  final String role;

  final int? employeeId;
  final String nip;
  final String nama;
  final String jabatan;
  final String jenisKelamin;
  final String telepon;
  final String? employeeEmail;
  final String status;
  final String? foto;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.employeeId,
    required this.nip,
    required this.nama,
    required this.jabatan,
    required this.jenisKelamin,
    required this.telepon,
    this.employeeEmail,
    required this.status,
    this.foto,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      username: json["username"] ?? "",
      email: json["email"] ?? "",
      role: json["role"] ?? "pegawai",

      employeeId: json["employee_id"],
      nip: json["nip"] ?? "",
      nama: json["nama"] ?? "",
      jabatan: json["jabatan"] ?? "",
      jenisKelamin: json["jenis_kelamin"] ?? "",
      telepon: json["telepon"] ?? "",
      employeeEmail: json["employee_email"],
      status: json["status"] ?? "",
      foto: json["foto"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "role": role,
      "employee_id": employeeId,
      "nip": nip,
      "nama": nama,
      "jabatan": jabatan,
      "jenis_kelamin": jenisKelamin,
      "telepon": telepon,
      "employee_email": employeeEmail,
      "status": status,
      "foto": foto,
    };
  }
}
