from datetime import date
from datetime import datetime

from apps.attendance.models import Attendance
from apps.master.models import Holiday


class AttendanceValidator:

    @staticmethod
    def already_checkin(employee):

        return Attendance.objects.filter(
            employee=employee,
            tanggal=date.today()
        ).exists()
