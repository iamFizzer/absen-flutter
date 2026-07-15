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

  });

  factory AttendanceTodayModel.fromJson(
      Map<String,dynamic> json){

    return AttendanceTodayModel(

      tanggal: json["tanggal"],

      office: json["office"],

      officeLatitude:
          double.parse(
              json["office_latitude"].toString()),

      officeLongitude:
          double.parse(
              json["office_longitude"].toString()),

      radius: json["radius"],

      jamMasuk: json["jam_masuk"],

      jamPulang: json["jam_pulang"],

      checkIn: json["check_in"],

      checkOut: json["check_out"],

      status: json["status"],

    );

  }

}