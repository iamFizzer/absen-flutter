import os
from apps.employees.models import Employee
from .models import FaceData
from .utils import FaceUtils

class RecognitionService:

    @staticmethod
    def register_face(user, image):

        employee = Employee.objects.filter(
            user=user
        ).first()

        if employee is None:

            return {
                "success": False,
                "message": "Data karyawan tidak ditemukan."
            }

        face = FaceData.objects.filter(
            employee=employee
        ).first()

        if face:

            face.image = image
            face.save()

        else:

            FaceData.objects.create(
                employee=employee,
                image=image
            )

        return {
            "success": True,
            "message": "Wajah berhasil didaftarkan."
        }

@staticmethod
def verify_face(user, image):

    employee = Employee.objects.filter(
        user=user
    ).first()

    if employee is None:

        return {
            "success": False,
            "message": "Karyawan tidak ditemukan."
        }

    face = FaceData.objects.filter(
        employee=employee
    ).first()

    if face is None:

        return {
            "success": False,
            "message": "Silakan registrasi wajah terlebih dahulu."
        }

    temp_path = os.path.join(
        settings.MEDIA_ROOT,
        "temp_verify.jpg"
    )

    with open(temp_path, "wb+") as destination:

        for chunk in image.chunks():

            destination.write(chunk)

    result = FaceUtils.verify_face(

        face.image.path,

        temp_path

    )

    os.remove(temp_path)

    return {

        "success": result["verified"],

        "distance": result["distance"],

        "threshold": result["threshold"],

        "message": "Wajah cocok."
        if result["verified"]
        else "Wajah tidak cocok."

    }