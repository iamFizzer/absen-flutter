import 'package:absensi_fr/modules/attendance/controllers/attendance_controller.dart';
import 'package:absensi_fr/modules/attendance/models/attendance_today_model.dart';
import 'package:absensi_fr/modules/attendance/widgets/attendance_action_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _TestAttendanceController extends AttendanceController {
  @override
  Future<void> initialize() async {}
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

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

  testWidgets('location card stops loading when location validation finishes', (
    tester,
  ) async {
    final controller = Get.put(_TestAttendanceController());
    controller.attendance.value = const AttendanceTodayModel(
      tanggal: '2026-07-28',
      office: 'Kantor Pusat',
      officeLatitude: -6.2,
      officeLongitude: 106.8,
      radius: 100,
      status: 'belum_checkin',
    );
    controller.isLocationLoading.value = true;

    await tester.pumpWidget(
      const GetMaterialApp(
        home: AttendanceActionPage(action: AttendanceActionType.checkIn),
      ),
    );
    expect(find.text('Mengambil lokasi terbaru...'), findsOneWidget);

    controller.locationError.value = 'Lokasi gagal dibaca.';
    controller.isLocationLoading.value = false;
    await tester.pump();

    expect(find.text('Mengambil lokasi terbaru...'), findsNothing);
    expect(find.text('Lokasi gagal dibaca.'), findsOneWidget);
    expect(find.text('Koordinat belum tersedia'), findsOneWidget);
  });
}
