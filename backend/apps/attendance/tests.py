from datetime import date, time, timedelta

from django.test import SimpleTestCase, TestCase
from django.contrib.auth.models import User
from django.utils import timezone
from rest_framework.test import APIRequestFactory, force_authenticate

from apps.common.utils.geolocation import GeoLocation
from apps.attendance.serializers import AttendanceSubmitSerializer
from apps.attendance.services import AttendanceService
from apps.master.models import Holiday, Shift
from apps.attendance.models import Attendance
from apps.attendance.models import LeaveRequest
from apps.attendance.views import (
    HolidayAttendanceApprovalDecisionView,
    HolidayAttendanceApprovalListView,
    LeaveRequestDecisionView,
    LeaveRequestListCreateView,
)
from apps.employees.models import Employee
from apps.offices.models import Office


class GeoLocationTests(SimpleTestCase):
    def test_same_coordinate_is_inside_radius(self):
        result = GeoLocation.check_radius(
            -6.2000000,
            106.8166667,
            -6.2000000,
            106.8166667,
            100,
        )

        self.assertEqual(result["distance"], 0)
        self.assertTrue(result["allowed"])

    def test_distant_coordinate_is_outside_radius(self):
        result = GeoLocation.check_radius(
            -6.2000000,
            106.8166667,
            -6.2100000,
            106.8166667,
            100,
        )

        self.assertGreater(result["distance"], 100)
        self.assertFalse(result["allowed"])


class AttendanceCoordinateSerializerTests(SimpleTestCase):
    def test_coordinate_with_seven_decimal_places_is_valid(self):
        serializer = AttendanceSubmitSerializer(data={
            "latitude": "-6.2000000",
            "longitude": "106.8166667",
        })

        # Selfie diuji terpisah; koordinat tidak boleh menghasilkan error.
        serializer.is_valid()
        self.assertNotIn("latitude", serializer.errors)
        self.assertNotIn("longitude", serializer.errors)

    def test_raw_high_precision_coordinate_is_rejected(self):
        serializer = AttendanceSubmitSerializer(data={
            "latitude": "-6.20000001234567",
            "longitude": "106.81666671234567",
        })

        serializer.is_valid()
        self.assertIn("latitude", serializer.errors)
        self.assertIn("longitude", serializer.errors)

    def test_action_must_be_check_in_or_check_out(self):
        serializer = AttendanceSubmitSerializer(data={
            "action": "check_in_again",
            "latitude": "-6.2000000",
            "longitude": "106.8166667",
        })

        serializer.is_valid()
        self.assertIn("action", serializer.errors)


class AttendanceScheduleTests(TestCase):
    def test_regular_weekday_uses_active_shift(self):
        Shift.objects.create(
            nama="Reguler",
            jam_masuk=time(8, 0),
            jam_pulang=time(16, 0),
            toleransi_menit=15,
        )

        schedule = AttendanceService.work_schedule(date(2026, 8, 3))

        self.assertTrue(schedule["is_open"])
        self.assertEqual(schedule["start"], time(8, 0))
        self.assertEqual(schedule["day_type"], "hari_kerja")

    def test_closed_holiday_disables_attendance(self):
        Holiday.objects.create(
            nama="Hari Kemerdekaan",
            tanggal=date(2026, 8, 17),
        )

        schedule = AttendanceService.work_schedule(date(2026, 8, 17))

        self.assertFalse(schedule["is_open"])
        self.assertEqual(schedule["message"], "Hari Kemerdekaan")

    def test_open_holiday_uses_custom_working_hours(self):
        Holiday.objects.create(
            nama="Uji presensi libur",
            tanggal=date(2026, 8, 17),
            boleh_presensi=True,
            jam_masuk=time(10, 0),
            jam_pulang=time(14, 0),
            toleransi_menit=5,
        )

        schedule = AttendanceService.work_schedule(date(2026, 8, 17))

        self.assertTrue(schedule["is_open"])
        self.assertEqual(schedule["start"], time(10, 0))
        self.assertEqual(schedule["end"], time(14, 0))


class HolidayAttendanceApprovalTests(TestCase):
    def setUp(self):
        self.admin = User.objects.create_user(
            username="admin-approval",
            password="secret123",
            is_staff=True,
        )
        self.user = User.objects.create_user(
            username="employee-approval",
            password="secret123",
        )
        self.office = Office.objects.create(
            nama="Kantor Uji",
            alamat="Alamat",
            latitude="-6.2000000",
            longitude="106.8166667",
            radius=100,
        )
        self.employee = Employee.objects.create(
            user=self.user,
            nip="APPROVAL-001",
            nama="Pegawai Approval",
            jenis_kelamin="L",
            tanggal_lahir=date(1990, 1, 1),
            alamat="Alamat",
            telepon="08123456789",
            email="approval@example.com",
            jabatan="Tester",
            office=self.office,
        )
        self.attendance = Attendance.objects.create(
            employee=self.employee,
            office=self.office,
            tanggal=date(2026, 8, 2),
            jam_masuk=time(9, 0),
            latitude="-6.2000000",
            longitude="106.8166667",
            jarak=0,
            selfie="attendance/test.jpg",
            status="hadir",
            holiday_approval_status="pending",
        )
        self.factory = APIRequestFactory()

    def test_pending_holiday_attendance_is_not_counted_in_recap(self):
        recap = AttendanceService.recap_by_date(
            date(2026, 8, 2),
            date(2026, 8, 2),
        )

        self.assertEqual(recap[0]["total_hadir"], 0)

    def test_admin_can_approve_and_attendance_enters_recap(self):
        request = self.factory.post(
            "/api/v1/attendance/holiday-approvals/decision/",
            {"decision": "approved", "note": "Disetujui untuk tugas khusus."},
            format="json",
        )
        force_authenticate(request, user=self.admin)
        response = HolidayAttendanceApprovalDecisionView.as_view()(
            request,
            attendance_id=self.attendance.id,
        )

        self.assertEqual(response.status_code, 200)
        self.attendance.refresh_from_db()
        self.assertEqual(self.attendance.holiday_approval_status, "approved")
        self.assertEqual(self.attendance.holiday_approved_by, self.admin)
        recap = AttendanceService.recap_by_date(
            date(2026, 8, 2),
            date(2026, 8, 2),
        )
        self.assertEqual(recap[0]["total_hadir"], 1)

    def test_employee_cannot_access_holiday_approval_list(self):
        request = self.factory.get("/api/v1/attendance/holiday-approvals/")
        force_authenticate(request, user=self.user)
        response = HolidayAttendanceApprovalListView.as_view()(request)

        self.assertEqual(response.status_code, 403)


class LeaveRequestTests(TestCase):
    def setUp(self):
        self.admin = User.objects.create_user("leave-admin", password="secret", is_staff=True)
        self.user = User.objects.create_user("leave-employee", password="secret")
        self.other_user = User.objects.create_user("other-employee", password="secret")
        self.office = Office.objects.create(
            nama="Kantor Cuti", alamat="Alamat", latitude="-6.2000000",
            longitude="106.8166667", radius=100,
        )
        self.employee = Employee.objects.create(
            user=self.user, nip="CUTI-001", nama="Pegawai Cuti", jenis_kelamin="L",
            tanggal_lahir=date(1990, 1, 1), alamat="Alamat", telepon="0812",
            email="cuti@example.com", jabatan="Tester", office=self.office,
        )
        self.other_employee = Employee.objects.create(
            user=self.other_user, nip="CUTI-002", nama="Pegawai Lain", jenis_kelamin="P",
            tanggal_lahir=date(1991, 1, 1), alamat="Alamat", telepon="0813",
            email="lain@example.com", jabatan="Tester", office=self.office,
        )
        self.factory = APIRequestFactory()

    def test_employee_can_submit_and_only_sees_own_requests(self):
        start = timezone.localdate() + timedelta(days=7)
        end = start + timedelta(days=1)
        request = self.factory.post(
            "/api/v1/attendance/leave-requests/",
            {"type": "cuti", "start_date": start.isoformat(), "end_date": end.isoformat(), "reason": "Keperluan keluarga"},
            format="json",
        )
        force_authenticate(request, user=self.user)
        with self.settings(USE_TZ=True):
            response = LeaveRequestListCreateView.as_view()(request)
        self.assertEqual(response.status_code, 201)

        LeaveRequest.objects.create(
            employee=self.other_employee, type="izin", start_date=end + timedelta(days=1),
            end_date=end + timedelta(days=1), reason="Keperluan lain",
        )
        list_request = self.factory.get("/api/v1/attendance/leave-requests/")
        force_authenticate(list_request, user=self.user)
        list_response = LeaveRequestListCreateView.as_view()(list_request)
        self.assertEqual(len(list_response.data["data"]), 1)

    def test_admin_approval_creates_attendance_for_workdays(self):
        leave_request = LeaveRequest.objects.create(
            employee=self.employee, type="cuti", start_date=date(2026, 8, 10),
            end_date=date(2026, 8, 11), reason="Keperluan keluarga",
        )
        request = self.factory.post("/decision/", {"decision": "approved"}, format="json")
        force_authenticate(request, user=self.admin)
        response = LeaveRequestDecisionView.as_view()(request, request_id=leave_request.id)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(Attendance.objects.filter(employee=self.employee, status="cuti").count(), 2)

    def test_rejection_requires_note(self):
        leave_request = LeaveRequest.objects.create(
            employee=self.employee, type="izin", start_date=date(2026, 8, 10),
            end_date=date(2026, 8, 10), reason="Keperluan",
        )
        request = self.factory.post("/decision/", {"decision": "rejected", "note": ""}, format="json")
        force_authenticate(request, user=self.admin)
        response = LeaveRequestDecisionView.as_view()(request, request_id=leave_request.id)
        self.assertEqual(response.status_code, 400)

# Create your tests here.
