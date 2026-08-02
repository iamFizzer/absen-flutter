class AttendanceTodayModel {
  final String tanggal;

  final String office;

  final double officeLatitude;

  final double officeLongitude;

  final int radius;

  final String? jamMasuk;

  final String? jamPulang;

  final String? checkIn;

  final String? checkOut;

  final String status;

  final bool presensiDibuka;

  final String jenisHari;

  final String? informasiHari;

  const AttendanceTodayModel({
    required this.tanggal,

    required this.office,

    required this.officeLatitude,

    required this.officeLongitude,

    required this.radius,

    this.jamMasuk,

    this.jamPulang,

    this.checkIn,

    this.checkOut,

    required this.status,

    required this.presensiDibuka,

    required this.jenisHari,

    this.informasiHari,
  });

  static String? _normalizeNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  factory AttendanceTodayModel.fromJson(Map<String, dynamic> json) {
    return AttendanceTodayModel(
      tanggal: json["tanggal"],

      office: json["office"],

      officeLatitude: double.parse(json["office_latitude"].toString()),

      officeLongitude: double.parse(json["office_longitude"].toString()),

      radius: json["radius"],

      jamMasuk: _normalizeNullableString(json["jam_masuk"]),

      jamPulang: _normalizeNullableString(json["jam_pulang"]),

      checkIn: _normalizeNullableString(json["check_in"]),

      checkOut: _normalizeNullableString(json["check_out"]),

      status: json["status"],

      presensiDibuka: json["presensi_dibuka"] ?? true,

      jenisHari: json["jenis_hari"] ?? "hari_kerja",

      informasiHari: _normalizeNullableString(json["informasi_hari"]),
    );
  }
}
