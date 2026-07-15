from datetime import date

from apps.employees.models import Employee
from apps.attendance.models import Attendance


class DashboardService:

    @staticmethod
    def dashboard(user):

        return {

            "nama": "Rena Wijaya",

            "jabatan": "STAFF IT",

            "shift": "PAGI",

            "jam_masuk": "08:00",

            "jam_pulang": "16:00",

            "check_in": None,

            "check_out": None,

            "status": "Belum Check In",

            "total_pegawai": 25,

            "total_kantor": 2,

            "total_presensi": 18,

            "total_terlambat": 1,

        }