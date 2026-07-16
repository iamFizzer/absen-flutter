from apps.employees.models import Employee


class AuthService:

    @staticmethod
    def profile(user):

        if user.is_superuser or user.is_staff:
            return {
                "id": user.id, "username": user.username,
                "email": user.email or "", "role": "superadmin" if user.is_superuser else "admin",
                "employee_id": None, "nip": "", "nama": user.get_full_name() or user.username,
                "jabatan": "Administrator", "jenis_kelamin": "", "telepon": "",
                "employee_email": user.email or None, "status": "aktif", "foto": None,
            }

        employee = Employee.objects.filter(
            user=user
        ).first()

        if employee is None:
            return None

        role = "pegawai"

        return {

            "id": user.id,

            "username": user.username,

            "email": user.email,

            "role": role,

            "employee_id": employee.id,

            "nip": employee.nip,

            "nama": employee.nama,

            "jabatan": employee.jabatan,

            "jenis_kelamin": employee.jenis_kelamin,

            "telepon": employee.telepon,

            "employee_email": employee.email,

            "status": employee.status,

            "foto": employee.foto.url if employee.foto else None,

        }
