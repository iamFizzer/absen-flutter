import '../../attendance/models/attendance_history_model.dart';

class DashboardModel {
  final String nama;
  final String jabatan;
  final String? faceImage;
  final String office;
  final String shift;
  final String? jamMasuk;
  final String? jamPulang;
  final String? checkIn;
  final String? checkOut;
  final String status;
  final int hadirBulanIni;
  final int terlambatBulanIni;
  final int durasiKerjaMenit;
  final List<AttendanceHistoryModel> historyBulanIni;

  const DashboardModel({
    required this.nama,
    required this.jabatan,
    this.faceImage,
    required this.office,
    required this.shift,
    this.jamMasuk,
    this.jamPulang,
    this.checkIn,
    this.checkOut,
    required this.status,
    required this.hadirBulanIni,
    required this.terlambatBulanIni,
    required this.durasiKerjaMenit,
    required this.historyBulanIni,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      nama: json["nama"] ?? "",
      jabatan: json["jabatan"] ?? "",
      faceImage: json["face_image"]?.toString(),
      office: json["office"] ?? "",
      shift: json["shift"] ?? "",
      jamMasuk: json["jam_masuk"],
      jamPulang: json["jam_pulang"],
      checkIn: json["check_in"],
      checkOut: json["check_out"],
      status: json["status"] ?? "belum_checkin",
      hadirBulanIni: json["hadir_bulan_ini"] ?? 0,
      terlambatBulanIni: json["terlambat_bulan_ini"] ?? 0,
      durasiKerjaMenit: json["durasi_kerja_menit"] ?? 0,
      historyBulanIni: (json["history_bulan_ini"] as List? ?? [])
          .map(
            (item) => AttendanceHistoryModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}
