import logging
import os
import tempfile

from django.conf import settings
from PIL import Image, ImageOps

from apps.employees.models import Employee

from .models import FaceData
from .utils import FaceUtils

logger = logging.getLogger(__name__)


class RecognitionService:

    @staticmethod
    def _normalized_image_path(image):
        was_closed = getattr(image, "closed", False)
        if was_closed and hasattr(image, "open"):
            image.open("rb")
        else:
            image.seek(0)
        with Image.open(image) as source:
            normalized = ImageOps.exif_transpose(source).convert("RGB")
            normalized.thumbnail((1600, 1600), Image.Resampling.LANCZOS)
            with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as temp:
                normalized.save(temp, format="JPEG", quality=95)
                path = temp.name
        if was_closed and hasattr(image, "close"):
            image.close()
        else:
            image.seek(0)
        return path

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

        temp_path = None
        reference_path = None

        try:
            try:
                temp_path = RecognitionService._normalized_image_path(image)
                reference_path = RecognitionService._normalized_image_path(face.image)
                result = FaceUtils.verify_face(
                    reference_path,
                    temp_path
                )
            except Exception as error:
                logger.exception("Face verification failed")
                details = str(error).lower()
                detection_failed = (
                    "face could not be detected" in details
                    or "face cannot be detected" in details
                    or "no face" in details
                )
                return {
                    "success": False,
                    "message": (
                        "Wajah tidak dapat dideteksi. Ambil foto ulang dengan pencahayaan yang baik."
                        if detection_failed
                        else "Layanan pengenalan wajah sedang bermasalah. Silakan coba kembali."
                    )
                }

        finally:

            if temp_path and os.path.exists(temp_path):
                os.remove(temp_path)
            if reference_path and os.path.exists(reference_path):
                os.remove(reference_path)

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
