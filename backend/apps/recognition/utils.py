import os

# DeepFace mencetak emoji saat mengunduh bobot model. Console Windows dengan
# encoding legacy dapat gagal mencetaknya dan membatalkan request presensi.
os.environ.setdefault("DEEPFACE_LOG_LEVEL", "30")

class FaceUtils:

    @staticmethod
    def verify_face(reference_image, new_image):

        # TensorFlow/DeepFace sangat berat. Import hanya ketika verifikasi
        # benar-benar digunakan agar startup Django tetap cepat dan stabil.
        from deepface import DeepFace

        result = DeepFace.verify(

            img1_path=reference_image,

            img2_path=new_image,

            model_name="ArcFace",

            detector_backend="opencv",

            enforce_detection=True

        )

        return result
