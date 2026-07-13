from apps.employees.models import Employee


class AuthService:

    @staticmethod
    def profile(user):

        employee = Employee.objects.filter(
            user=user
        ).first()

        if employee is None:
            return None

        # Role
        if user.is_superuser:
            role = "superadmin"
        elif user.is_staff:
            role = "admin"
        else:
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