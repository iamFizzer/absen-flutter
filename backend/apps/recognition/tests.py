from io import BytesIO

from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import SimpleTestCase
from PIL import Image

from .serializers import VerifyFaceSerializer


class FaceImageQualityValidationTests(SimpleTestCase):
    @staticmethod
    def _upload(image, name="face.jpg"):
        output = BytesIO()
        image.save(output, format="JPEG", quality=95)
        return SimpleUploadedFile(
            name,
            output.getvalue(),
            content_type="image/jpeg",
        )

    def test_rejects_low_resolution_image_with_specific_message(self):
        image = Image.new("RGB", (120, 120), "gray")
        serializer = VerifyFaceSerializer(data={"image": self._upload(image)})

        self.assertFalse(serializer.is_valid())
        self.assertIn("Resolusi foto terlalu rendah", str(serializer.errors))

    def test_rejects_blurry_image_with_specific_message(self):
        image = Image.new("RGB", (480, 480), (128, 128, 128))
        serializer = VerifyFaceSerializer(data={"image": self._upload(image)})

        self.assertFalse(serializer.is_valid())
        self.assertIn("Foto wajah buram", str(serializer.errors))

    def test_accepts_clear_well_lit_image(self):
        image = Image.new("RGB", (480, 480), "white")
        pixels = image.load()
        for y in range(480):
            for x in range(480):
                shade = 45 if (x // 24 + y // 24) % 2 == 0 else 205
                pixels[x, y] = (shade, shade, shade)
        serializer = VerifyFaceSerializer(data={"image": self._upload(image)})

        self.assertTrue(serializer.is_valid(), serializer.errors)
