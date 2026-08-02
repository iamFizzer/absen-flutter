import calendar
from datetime import date, datetime, time, timedelta

from django.db import transaction
from django.conf import settings
from django.utils import timezone

from apps.attendance.models import Attendance
from apps.common.utils.geolocation import GeoLocation
from apps.employees.models import Employee
from apps.master.models import Shift
from apps.master.models import Holiday
from apps.recognition.services import RecognitionService


class AttendanceError(Exception):
    pass


class AttendanceService:

    AUTO_CHECKOUT_TIME = time(23, 59)

    @staticmethod
    def work_schedule(day):
        holiday = Holiday.objects.filter(tanggal=day).first()
        shift = Shift.objects.filter(aktif=True).order_by("jam_masuk").first()
        if holiday is not None:
            return {
                "is_open": holiday.boleh_presensi,
                "day_type": holiday.jenis,
                "message": holiday.nama,
                "start": holiday.jam_masuk if holiday.boleh_presensi else None,
                "end": holiday.jam_pulang if holiday.boleh_presensi else None,
                "tolerance": holiday.toleransi_menit,
            }
        if day.weekday() >= 5:
            return {
                "is_open": False,
                "day_type": "akhir_pekan",
                "message": "Akhir pekan",
                "start": None,
                "end": None,
                "tolerance": 0,
            }
        return {
            "is_open": True,
            "day_type": "hari_kerja",
            "message": None,
            "start": shift.jam_masuk if shift else None,
            "end": shift.jam_pulang if shift else None,
            "tolerance": shift.toleransi_menit if shift else 0,
        }

    @staticmethod
    def finalize_previous_days(employee=None):
        queryset = Attendance.objects.filter(
            tanggal__lt=timezone.localdate(),
            jam_masuk__isnull=False,
            jam_pulang__isnull=True,
        )
        if employee is not None:
            queryset = queryset.filter(employee=employee)

        queryset.update(
            jam_pulang=AttendanceService.AUTO_CHECKOUT_TIME,
            catatan="Check-out otomatis karena tanggal telah berganti.",
            updated_at=timezone.now(),
        )

    @staticmethod
    def today(user):

        employee = Employee.objects.filter(
            user=user
        ).select_related("office").first()

        if employee is None:
            return None

        AttendanceService.finalize_previous_days(employee)

        today = timezone.localdate()
        attendance = Attendance.objects.filter(
            employee=employee,
            tanggal=today
        ).first()

        schedule = AttendanceService.work_schedule(today)

        return {

            "tanggal": today,

            "office": employee.office.nama,

            "office_latitude": float(employee.office.latitude),

            "office_longitude": float(employee.office.longitude),

            "radius": employee.office.radius,

            "jam_masuk": schedule["start"],

            "jam_pulang": schedule["end"],

            "check_in": attendance.jam_masuk if attendance else None,

            "check_out": attendance.jam_pulang if attendance else None,

            "status": AttendanceService.display_status(attendance),

            "presensi_dibuka": schedule["is_open"],

            "jenis_hari": schedule["day_type"],

            "informasi_hari": schedule["message"],

        }

    @staticmethod
    @transaction.atomic
    def submit(user, action, latitude, longitude, selfie):
        employee = (
            Employee.objects.select_for_update()
            .select_related("office")
            .filter(user=user, status="aktif")
            .first()
        )
        if employee is None:
            raise AttendanceError("Data karyawan aktif tidak ditemukan.")

        today = timezone.localdate()
        schedule = AttendanceService.work_schedule(today)
        attendance = (
            Attendance.objects.select_for_update()
            .filter(employee=employee, tanggal=today)
            .first()
        )
        if action == "check_in" and attendance is not None:
            raise AttendanceError("Anda sudah check-in hari ini.")
        if action == "check_in" and not schedule["is_open"]:
            raise AttendanceError(
                f"Hari ini {schedule['message']}. Presensi tidak dibuka."
            )
        if action == "check_out" and attendance is None:
            raise AttendanceError("Anda belum check-in hari ini.")
        if action == "check_out" and attendance.jam_pulang is not None:
            raise AttendanceError("Anda sudah check-out hari ini.")

        office = employee.office
        location = GeoLocation.check_radius(
            office.latitude,
            office.longitude,
            latitude,
            longitude,
            office.radius,
        )
        if settings.ATTENDANCE_ENFORCE_RADIUS and not location["allowed"]:
            raise AttendanceError(
                f"Anda berada di luar radius kantor ({location['distance']} meter)."
            )

        face_result = RecognitionService.verify_face(user, selfie)
        if not face_result.get("success"):
            raise AttendanceError(face_result.get("message", "Verifikasi wajah gagal."))
        if not face_result.get("verified"):
            raise AttendanceError("Wajah tidak cocok dengan data yang terdaftar.")
        selfie.seek(0)

        current_time = timezone.localtime().time().replace(microsecond=0)

        if action == "check_in":
            status = "hadir"
            if schedule["start"]:
                deadline = (
                    datetime.combine(today, schedule["start"])
                    + timedelta(minutes=schedule["tolerance"])
                ).time()
                if current_time > deadline:
                    status = "terlambat"

            attendance = Attendance.objects.create(
                employee=employee,
                office=office,
                tanggal=today,
                jam_masuk=current_time,
                latitude=latitude,
                longitude=longitude,
                jarak=location["distance"],
                selfie=selfie,
                face_score=face_result.get("confidence", 0),
                status=status,
                holiday_approval_status=(
                    "pending"
                    if schedule["day_type"] in ("hari_libur", "cuti_bersama")
                    else "not_required"
                ),
            )
            action = "check_in"
            message = (
                "Presensi hari libur berhasil dikirim dan menunggu approval admin."
                if attendance.holiday_approval_status == "pending"
                else "Check-in berhasil."
            )
        else:
            attendance.jam_pulang = current_time
            attendance.face_score = face_result.get("confidence", attendance.face_score)
            attendance.save(update_fields=["jam_pulang", "face_score", "updated_at"])
            action = "check_out"
            message = "Check-out berhasil."
        return {
            "action": action,
            "message": message,
            "distance": location["distance"],
            "face_score": face_result.get("confidence", 0),
            "attendance": AttendanceService.today(user),
        }

    @staticmethod
    def display_status(attendance):
        if attendance is None:
            return "belum_checkin"
        if attendance.holiday_approval_status == "pending":
            return "menunggu_approval"
        if attendance.holiday_approval_status == "rejected":
            return "ditolak"
        return attendance.status

    @staticmethod
    def history(user, year=None, month=None):
        employee = Employee.objects.filter(user=user).first()
        if employee is None:
            return None

        AttendanceService.finalize_previous_days(employee)
        today = timezone.localdate()
        year = year or today.year
        month = month or today.month
        if month < 1 or month > 12:
            year, month = today.year, today.month
        _, last_day = calendar.monthrange(year, month)
        start = date(year, month, 1)
        end = min(date(year, month, last_day), today)

        records = {
            item.tanggal: item
            for item in Attendance.objects.filter(
                employee=employee,
                tanggal__range=(start, end),
            )
        }
        holidays = set(
            Holiday.objects.filter(tanggal__range=(start, end)).values_list(
                "tanggal", flat=True
            )
        )

        result = []
        current = start
        while current <= end:
            record = records.get(current)
            is_workday = current.weekday() < 5 and current not in holidays
            if record is not None:
                result.append({
                    "tanggal": current,
                    "check_in": record.jam_masuk,
                    "check_out": record.jam_pulang,
                    "status": AttendanceService.display_status(record),
                    "catatan": (
                        record.holiday_approval_note
                        if record.holiday_approval_status == "rejected"
                        else record.catatan
                    ),
                })
            elif is_workday:
                result.append({
                    "tanggal": current,
                    "check_in": None,
                    "check_out": None,
                    "status": "belum_checkin" if current == today else "alpa",
                    "catatan": None,
                })
            current += timedelta(days=1)

        return list(reversed(result))

    @staticmethod
    def monthly_recap(year=None, month=None):
        today = timezone.localdate()
        year = year or today.year
        month = month or today.month
        AttendanceService.finalize_previous_days()

        result = []
        for employee in Employee.objects.filter(status="aktif").select_related(
            "face"
        ).order_by("nama"):
            history = AttendanceService.history(employee.user, year, month)
            counts = {
                "hadir": 0,
                "terlambat": 0,
                "izin": 0,
                "sakit": 0,
                "cuti": 0,
                "alpa": 0,
            }
            for item in history:
                if item["status"] in counts:
                    counts[item["status"]] += 1
            result.append({
                "employee_id": employee.id,
                "nip": employee.nip,
                "nama": employee.nama,
                "face_image": employee.face.image.url
                if hasattr(employee, "face") and employee.face.image
                else None,
                **counts,
                "total_hadir": counts["hadir"] + counts["terlambat"],
            })
        return result

    @staticmethod
    def recap_by_date(start_date, end_date):
        AttendanceService.finalize_previous_days()
        result = []
        for employee in Employee.objects.filter(status="aktif").select_related(
            "face"
        ).order_by("nama"):
            records = AttendanceService._history_range(employee, start_date, end_date)
            counts = {
                key: 0
                for key in ("hadir", "terlambat", "izin", "sakit", "cuti", "alpa")
            }
            for item in records:
                if item["status"] in counts:
                    counts[item["status"]] += 1
            result.append({
                "employee_id": employee.id,
                "nip": employee.nip,
                "nama": employee.nama,
                "face_image": employee.face.image.url
                if hasattr(employee, "face") and employee.face.image
                else None,
                **counts,
                "total_hadir": counts["hadir"] + counts["terlambat"],
            })
        return result

    @staticmethod
    def _history_range(employee, start, end):
        today = timezone.localdate()
        end = min(end, today)
        if start > end:
            return []
        records = {
            item.tanggal: item
            for item in Attendance.objects.filter(
                employee=employee,
                tanggal__range=(start, end),
            )
        }
        holidays = set(
            Holiday.objects.filter(tanggal__range=(start, end)).values_list(
                "tanggal", flat=True
            )
        )
        result = []
        current = start
        while current <= end:
            record = records.get(current)
            if record is not None:
                result.append({"status": AttendanceService.display_status(record)})
            elif current.weekday() < 5 and current not in holidays:
                result.append({
                    "status": "belum_checkin" if current == today else "alpa"
                })
            current += timedelta(days=1)
        return result
