from django.db import transaction
from django.utils import timezone

from apps.common.utils.geolocation import GeoLocation
from apps.employees.models import Employee
from apps.recognition.services import RecognitionService

from .models import Attendance
from .validators import AttendanceValidator


class AttendanceService:

    @staticmethod
    def validate_location(user, latitude, longitude):

        employee = (
            Employee.objects
            .select_related("office")
            .filter(
                user=user,
                status="aktif"
            )
            .first()
        )

        if employee is None:
            return {
                "success": False,
                "message": "Data karyawan tidak ditemukan."
            }

        office = employee.office

        if office is None:
            return {
                "success": False,
                "message": "Office belum ditentukan."
            }

        if not office.status:
            return {
                "success": False,
                "message": "Office tidak aktif."
            }

        geo = GeoLocation.check_radius(
            office.latitude,
            office.longitude,
            latitude,
            longitude,
            office.radius
        )

        if not geo["allowed"]:
            return {
                "success": False,
                "message": "Anda berada di luar radius kantor.",
                "distance": geo["distance"]
            }

        return {
            "success": True,
            "employee": employee,
            "office": office,
            "distance": geo["distance"]
        }

    @staticmethod
    def check_in(
        user,
        latitude,
        longitude,
        image
    ):

        # 1. Validasi Lokasi
        location = AttendanceService.validate_location(
            user,
            latitude,
            longitude
        )

        if not location["success"]:
            return location

        employee = location["employee"]

        # 2. Sudah Presensi?
        if AttendanceValidator.already_checkin(employee):
            return {
                "success": False,
                "message": "Hari ini Anda sudah melakukan presensi."
            }

        # 3. Face Recognition
        face = RecognitionService.verify_face(
            user,
            image
        )

        if not face["success"]:
            return face

        if not face["verified"]:
            return {
                "success": False,
                "message": face["message"]
            }

        # 4. Simpan Attendance
        with transaction.atomic():

            attendance = Attendance.objects.create(

                employee=employee,

                office=location["office"],

                tanggal=timezone.localdate(),

                jam_masuk=timezone.localtime().time(),

                latitude=latitude,

                longitude=longitude,

                jarak=location["distance"],

                selfie=image,

                status="hadir"
            )

        return {

            "success": True,

            "message": "Check In berhasil.",

            "attendance_id": attendance.id,

            "employee": employee.nama,

            "office": location["office"].nama,

            "distance": location["distance"],

            "confidence": face["confidence"]

        }

        @staticmethod
        def check_out(
            user,
            latitude,
            longitude
        ):

            location = AttendanceService.validate_location(
                user,
                latitude,
                longitude
            )

            if not location["success"]:
                return location

            employee = location["employee"]

            attendance = Attendance.objects.filter(
                employee=employee,
                tanggal=timezone.localdate()
            ).first()

            if attendance is None:
                return {
                    "success": False,
                    "message": "Anda belum melakukan check in."
                }

            if attendance.jam_pulang:
                return {
                    "success": False,
                    "message": "Anda sudah melakukan check out."
                }

            attendance.jam_pulang = timezone.localtime().time()

            attendance.save()

            return {
                "success": True,
                "message": "Check Out berhasil.",
                "jam_pulang": attendance.jam_pulang
            }
        
        @staticmethod
        def history(user):

            employee = Employee.objects.filter(

                user=user,

                status="aktif"

            ).first()

            if employee is None:

                return Attendance.objects.none()

            return Attendance.objects.filter(

                employee=employee

            ).select_related(

                "office"

            ).order_by(

                "-tanggal",

                "-created_at"

    )