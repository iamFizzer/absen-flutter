from datetime import date, datetime, timedelta

from django.db.models import Avg, Count, Q
from django.utils import timezone

from apps.attendance.models import Attendance
from apps.attendance.services import AttendanceService
from apps.employees.models import Employee
from apps.master.models import Shift


class DashboardService:
    @staticmethod
    def dashboard(user):
        employee = (
            Employee.objects.select_related("office", "face")
            .filter(user=user)
            .first()
        )
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
            "face_image": (
                employee.face.image.url
                if hasattr(employee, "face") and employee.face.image
                else None
            ),
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

    @staticmethod
    def business_intelligence(start_date=None, end_date=None):
        today = timezone.localdate()
        end = min(end_date or today, today)
        start = start_date or (end - timedelta(days=29))
        if start > end:
            start, end = end, start

        AttendanceService.finalize_previous_days()

        active_employees = Employee.objects.filter(status="aktif")
        total_employees = active_employees.count()
        attendances = Attendance.objects.filter(tanggal__range=(start, end))

        present_count = attendances.filter(status__in=["hadir", "terlambat"]).count()
        late_count = attendances.filter(status="terlambat").count()
        absent_count = attendances.filter(status="alpa").count()
        leave_count = attendances.filter(status__in=["izin", "sakit", "cuti"]).count()
        completed_count = attendances.filter(jam_masuk__isnull=False, jam_pulang__isnull=False).count()

        workdays = DashboardService._workday_count(start, end)
        expected_presence = total_employees * workdays
        attendance_rate = DashboardService._percentage(present_count, expected_presence)
        late_rate = DashboardService._percentage(late_count, present_count)
        completion_rate = DashboardService._percentage(completed_count, present_count)

        today_attendance = Attendance.objects.filter(tanggal=today)
        checked_in_today = today_attendance.filter(jam_masuk__isnull=False).count()
        checked_out_today = today_attendance.filter(jam_pulang__isnull=False).count()

        status_rows = attendances.values("status").annotate(total=Count("id"))
        status_map = {row["status"]: row["total"] for row in status_rows}

        daily_rows = {
            row["tanggal"]: row
            for row in attendances.values("tanggal").annotate(
                hadir=Count("id", filter=Q(status="hadir")),
                terlambat=Count("id", filter=Q(status="terlambat")),
                izin=Count("id", filter=Q(status__in=["izin", "sakit", "cuti"])),
                alpa=Count("id", filter=Q(status="alpa")),
            )
        }
        daily_trend = []
        current = start
        while current <= end:
            row = daily_rows.get(current, {})
            present = row.get("hadir", 0) + row.get("terlambat", 0)
            daily_trend.append({
                "date": current,
                "label": current.strftime("%d/%m"),
                "hadir": present,
                "terlambat": row.get("terlambat", 0),
                "izin": row.get("izin", 0),
                "alpa": row.get("alpa", 0),
            })
            current += timedelta(days=1)

        office_rows = (
            active_employees.values("office_id", "office__nama")
            .annotate(
                employees=Count("id"),
                hadir=Count(
                    "attendance",
                    filter=Q(attendance__tanggal__range=(start, end), attendance__status__in=["hadir", "terlambat"]),
                ),
                terlambat=Count(
                    "attendance",
                    filter=Q(attendance__tanggal__range=(start, end), attendance__status="terlambat"),
                ),
                face_score=Avg(
                    "attendance__face_score",
                    filter=Q(attendance__tanggal__range=(start, end), attendance__face_score__gt=0),
                ),
            )
            .order_by("office__nama")
        )
        office_performance = []
        for row in office_rows:
            expected = row["employees"] * workdays
            office_performance.append({
                "office": row["office__nama"],
                "employees": row["employees"],
                "hadir": row["hadir"],
                "terlambat": row["terlambat"],
                "attendance_rate": DashboardService._percentage(row["hadir"], expected),
                "late_rate": DashboardService._percentage(row["terlambat"], row["hadir"]),
                "average_face_score": round(row["face_score"] or 0, 2),
            })

        employee_rows = (
            active_employees.values("id", "nama", "jabatan", "office__nama")
            .annotate(
                hadir=Count(
                    "attendance",
                    filter=Q(attendance__tanggal__range=(start, end), attendance__status__in=["hadir", "terlambat"]),
                ),
                terlambat=Count(
                    "attendance",
                    filter=Q(attendance__tanggal__range=(start, end), attendance__status="terlambat"),
                ),
                alpa=Count(
                    "attendance",
                    filter=Q(attendance__tanggal__range=(start, end), attendance__status="alpa"),
                ),
            )
            .order_by("-terlambat", "alpa", "nama")[:8]
        )
        attention_list = [
            {
                "employee_id": row["id"],
                "nama": row["nama"],
                "jabatan": row["jabatan"],
                "office": row["office__nama"],
                "hadir": row["hadir"],
                "terlambat": row["terlambat"],
                "alpa": row["alpa"],
            }
            for row in employee_rows
            if row["terlambat"] or row["alpa"]
        ]

        return {
            "period": {"start_date": start, "end_date": end, "workdays": workdays},
            "summary": {
                "active_employees": total_employees,
                "expected_presence": expected_presence,
                "present_count": present_count,
                "late_count": late_count,
                "absent_count": absent_count,
                "leave_count": leave_count,
                "attendance_rate": attendance_rate,
                "late_rate": late_rate,
                "completion_rate": completion_rate,
                "checked_in_today": checked_in_today,
                "checked_out_today": checked_out_today,
                "not_checked_in_today": max(total_employees - checked_in_today, 0),
            },
            "status_breakdown": [
                {"status": key, "total": status_map.get(key, 0)}
                for key in ["hadir", "terlambat", "izin", "sakit", "cuti", "alpa"]
            ],
            "daily_trend": daily_trend,
            "office_performance": office_performance,
            "attention_list": attention_list,
        }

    @staticmethod
    def _percentage(value, total):
        return round((value / total) * 100, 1) if total else 0

    @staticmethod
    def _workday_count(start, end):
        count = 0
        current = start
        while current <= end:
            if current.weekday() < 5:
                count += 1
            current += timedelta(days=1)
        return count

    @staticmethod
    def parse_date(value):
        if not value:
            return None
        try:
            return datetime.strptime(value, "%Y-%m-%d").date()
        except ValueError:
            return None
