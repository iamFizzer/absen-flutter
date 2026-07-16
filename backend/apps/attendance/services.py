from datetime import datetime, timedelta

from django.db import transaction
from django.conf import settings
from django.utils import timezone

from apps.attendance.models import Attendance
from apps.common.utils.geolocation import GeoLocation
from apps.employees.models import Employee
from apps.master.models import Shift
from apps.recognition.services import RecognitionService


class AttendanceError(Exception):
    pass


class AttendanceService:

    @staticmethod
    def today(user):

        employee = Employee.objects.filter(
            user=user
        ).select_related("office").first()

        if employee is None:
            return None

        attendance = Attendance.objects.filter(
            employee=employee,
            tanggal=timezone.localdate()
        ).first()

        return {

            "tanggal": timezone.localdate(),

            "office": employee.office.nama,

            "office_latitude": float(employee.office.latitude),

            "office_longitude": float(employee.office.longitude),

            "radius": employee.office.radius,

            "jam_masuk": attendance.jam_masuk if attendance else None,

            "jam_pulang": attendance.jam_pulang if attendance else None,

            "check_in": attendance.jam_masuk if attendance else None,

            "check_out": attendance.jam_pulang if attendance else None,

            "status": attendance.status if attendance else "belum_checkin",

        }

    @staticmethod
    @transaction.atomic
    def submit(user, latitude, longitude, selfie):
        employee = (
            Employee.objects.select_for_update()
            .select_related("office")
            .filter(user=user, status="aktif")
            .first()
        )
        if employee is None:
            raise AttendanceError("Data karyawan aktif tidak ditemukan.")

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

        today = timezone.localdate()
        current_time = timezone.localtime().time().replace(microsecond=0)
        attendance = (
            Attendance.objects.select_for_update()
            .filter(employee=employee, tanggal=today)
            .first()
        )

        if attendance is None:
            shift = Shift.objects.filter(aktif=True).order_by("jam_masuk").first()
            status = "hadir"
            if shift:
                deadline = (
                    datetime.combine(today, shift.jam_masuk)
                    + timedelta(minutes=shift.toleransi_menit)
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
            )
            action = "check_in"
            message = "Check-in berhasil."
        elif attendance.jam_pulang is None:
            attendance.jam_pulang = current_time
            attendance.face_score = face_result.get("confidence", attendance.face_score)
            attendance.save(update_fields=["jam_pulang", "face_score", "updated_at"])
            action = "check_out"
            message = "Check-out berhasil."
        else:
            raise AttendanceError("Check-in dan check-out hari ini sudah selesai.")

        return {
            "action": action,
            "message": message,
            "distance": location["distance"],
            "face_score": face_result.get("confidence", 0),
            "attendance": AttendanceService.today(user),
        }
