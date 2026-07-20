from datetime import datetime

from django.utils import timezone

from apps.attendance.models import Attendance
from apps.attendance.services import AttendanceService
from apps.employees.models import Employee
from apps.master.models import Shift


class DashboardService:
    @staticmethod
    def dashboard(user):
        employee = Employee.objects.select_related("office").filter(user=user).first()
        if employee is None:
            return None

        AttendanceService.finalize_previous_days(employee)

        today = timezone.localdate()
        attendance = Attendance.objects.filter(
            employee=employee, tanggal=today
        ).first()
        shift = Shift.objects.filter(aktif=True).order_by("jam_masuk").first()
        month_records = Attendance.objects.filter(
            employee=employee,
            tanggal__year=today.year,
            tanggal__month=today.month,
        )

        if attendance is None:
            status = "belum_checkin"
        elif attendance.jam_pulang is None:
            status = "sudah_checkin"
        else:
            status = "selesai"

        duration_minutes = 0
        if attendance and attendance.jam_masuk:
            started_at = timezone.make_aware(
                datetime.combine(today, attendance.jam_masuk)
            )
            finished_at = (
                timezone.make_aware(datetime.combine(today, attendance.jam_pulang))
                if attendance.jam_pulang
                else timezone.localtime()
            )
            duration_minutes = max(
                0,
                int((finished_at - started_at).total_seconds() // 60),
            )

        history = AttendanceService.history(user, today.year, today.month) or []

        return {
            "nama": employee.nama,
            "jabatan": employee.jabatan,
            "office": employee.office.nama,
            "shift": shift.nama if shift else "Belum diatur",
            "jam_masuk": shift.jam_masuk if shift else None,
            "jam_pulang": shift.jam_pulang if shift else None,
            "check_in": attendance.jam_masuk if attendance else None,
            "check_out": attendance.jam_pulang if attendance else None,
            "status": status,
            "hadir_bulan_ini": month_records.filter(
                status__in=["hadir", "terlambat"]
            ).count(),
            "terlambat_bulan_ini": month_records.filter(status="terlambat").count(),
            "durasi_kerja_menit": duration_minutes,
            "history_bulan_ini": history,
        }
