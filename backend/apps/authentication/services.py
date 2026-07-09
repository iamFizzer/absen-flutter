from apps.employees.models import Employee


class AuthService:

    @staticmethod
    def profile(user):

        employee = Employee.objects.filter(
            user=user
        ).first()

        if employee is None:
            return None

        foto = None

        if employee.foto:
            foto = employee.foto.url

        return {

            "user": {

                "id": user.id,

                "username": user.username,

                "email": user.email,

            },

            "employee": {

                "id": employee.id,

                "nip": employee.nip,

                "nama": employee.nama,

                "jabatan": employee.jabatan,

                "jenis_kelamin": employee.jenis_kelamin,

                "telepon": employee.telepon,

                "email": employee.email,

                "status": employee.status,

                "foto": foto,

            }

        }