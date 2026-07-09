from datetime import date

from apps.employees.models import Employee
from apps.attendance.models import Attendance


class DashboardService:

    @staticmethod
    def get_dashboard(user):

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

            "employee": {

                "id": employee.id,

                "nip": employee.nip,

                "nama": employee.nama,

                "jabatan": employee.jabatan,

            },

            "office": {

                "id": employee.office.id,

                "nama": employee.office.nama,

                "radius": employee.office.radius,

            },

            "attendance": {

                "today": attendance is not None,

                "check_in": attendance.jam_masuk if attendance else None,

                "check_out": attendance.jam_pulang if attendance else None,

            }

        }