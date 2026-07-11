import os
import tempfile

from django.conf import settings

from apps.employees.models import Employee

from .models import FaceData
from .utils import FaceUtils


class RecognitionService:

    @staticmethod
    def register_face(user, image):

        employee = Employee.objects.filter(
            user=user,
            status="aktif"
        ).first()

        if employee is None:
            return {
                "success": False,
                "message": "Data karyawan tidak ditemukan."
            }

        face, created = FaceData.objects.get_or_create(
            employee=employee
        )

        face.image = image
        face.encoding = None
        face.save()

        return {
            "success": True,
            "message": "Wajah berhasil didaftarkan."
        }

    @staticmethod
    def verify_face(user, image):

        employee = Employee.objects.filter(
            user=user,
            status="aktif"
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

        with tempfile.NamedTemporaryFile(
            suffix=".jpg",
            delete=False
        ) as temp:

            for chunk in image.chunks():
                temp.write(chunk)

            temp_path = temp.name

        try:

            result = FaceUtils.verify_face(
                face.image.path,
                temp_path
            )

        finally:

            if os.path.exists(temp_path):
                os.remove(temp_path)

        confidence = max(
            0,
            round(
                (1 - result["distance"]) * 100,
                2
            )
        )

        return {

            "success": True,

            "verified": result["verified"],

            "confidence": confidence,

            "distance": result["distance"],

            "threshold": result["threshold"],

            "message": (
                "Wajah cocok."
                if result["verified"]
                else "Wajah tidak cocok."
            )

        }