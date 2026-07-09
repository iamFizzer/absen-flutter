from deepface import DeepFace


class FaceUtils:

    @staticmethod
    def verify_face(reference_image, new_image):

        result = DeepFace.verify(

            img1_path=reference_image,

            img2_path=new_image,

            model_name="ArcFace",

            detector_backend="opencv",

            enforce_detection=False

        )

        return result