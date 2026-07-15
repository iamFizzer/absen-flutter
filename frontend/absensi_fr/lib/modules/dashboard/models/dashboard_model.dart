class DashboardModel {
  final String nama;
  final String jabatan;

  final String shift;
  final String jamMasuk;
  final String jamPulang;

  final String? checkIn;
  final String? checkOut;

  final String status;

  final int totalPegawai;
  final int totalKantor;
  final int totalPresensi;
  final int totalTerlambat;

  const DashboardModel({
    required this.nama,
    required this.jabatan,
    required this.shift,
    required this.jamMasuk,
    required this.jamPulang,
    this.checkIn,
    this.checkOut,
    required this.status,
    required this.totalPegawai,
    required this.totalKantor,
    required this.totalPresensi,
    required this.totalTerlambat,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      nama: json["nama"] ?? "",
      jabatan: json["jabatan"] ?? "",
      shift: json["shift"] ?? "",
      jamMasuk: json["jam_masuk"] ?? "",
      jamPulang: json["jam_pulang"] ?? "",
      checkIn: json["check_in"],
      checkOut: json["check_out"],
      status: json["status"] ?? "",
      totalPegawai: json["total_pegawai"] ?? 0,
      totalKantor: json["total_kantor"] ?? 0,
      totalPresensi: json["total_presensi"] ?? 0,
      totalTerlambat: json["total_terlambat"] ?? 0,
    );
  }
}