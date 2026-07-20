class AttendanceHistoryModel {
  final String tanggal;
  final String? checkIn;
  final String? checkOut;
  final String status;
  final String? catatan;

  const AttendanceHistoryModel({
    required this.tanggal,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.catatan,
  });

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryModel(
      tanggal: json['tanggal'].toString(),
      checkIn: json['check_in']?.toString(),
      checkOut: json['check_out']?.toString(),
      status: json['status']?.toString() ?? 'alpa',
      catatan: json['catatan']?.toString(),
    );
  }
}
