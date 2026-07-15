from datetime import date

from apps.attendance.models import Attendance
from apps.employees.models import Employee


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
            tanggal=date.today()
        ).first()

        return {

            "tanggal": date.today(),

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