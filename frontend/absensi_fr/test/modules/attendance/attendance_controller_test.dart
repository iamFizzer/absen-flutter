import 'package:absensi_fr/modules/attendance/controllers/attendance_controller.dart';
import 'package:absensi_fr/modules/attendance/models/attendance_today_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendanceController', () {
    test('uses check_in action when API returns empty attendance times', () {
      final controller = AttendanceController();
      controller.attendance.value = AttendanceTodayModel.fromJson({
        'tanggal': '2026-07-28',
        'office': 'Kantor Pusat',
        'office_latitude': -6.2,
        'office_longitude': 106.8,
        'radius': 100,
        'jam_masuk': '',
        'jam_pulang': ' ',
        'check_in': '',
        'check_out': ' ',
        'status': 'belum_checkin',
      });
      controller.isInsideOffice.value = true;

      expect(controller.attendance.value!.checkIn, isNull);
      expect(controller.attendance.value!.checkOut, isNull);
      expect(controller.action, 'check_in');
      expect(controller.actionLabel, 'MASUK');
      expect(controller.canSubmit, isTrue);
    });

    test('uses check_out action after check-in has been recorded', () {
      final controller = AttendanceController();
      controller.attendance.value = const AttendanceTodayModel(
        tanggal: '2026-07-28',
        office: 'Kantor Pusat',
        officeLatitude: -6.2,
        officeLongitude: 106.8,
        radius: 100,
        checkIn: '08:00',
        status: 'sudah_checkin',
      );

      expect(controller.action, 'check_out');
      expect(controller.actionLabel, 'PULANG');
    });
  });
}
