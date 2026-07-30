from PIL import Image, ImageFilter, ImageStat
from rest_framework import serializers
from .models import FaceData


def validate_face_image(image):
    try:
        image.seek(0)
        with Image.open(image) as source:
            normalized = source.convert("L")
            width, height = normalized.size
            if width < 240 or height < 240:
                raise serializers.ValidationError(
                    "Resolusi foto terlalu rendah. Gunakan foto minimal 240 x 240 piksel."
                )

            brightness = ImageStat.Stat(normalized).mean[0]
            if brightness < 35:
                raise serializers.ValidationError(
                    "Foto terlalu gelap. Ambil ulang di tempat dengan pencahayaan yang cukup."
                )
            if brightness > 225:
                raise serializers.ValidationError(
                    "Foto terlalu terang. Hindari cahaya langsung ke kamera."
                )

            contrast = ImageStat.Stat(normalized).stddev[0]
            edge_detail = ImageStat.Stat(
                normalized.filter(ImageFilter.FIND_EDGES)
            ).stddev[0]
            if contrast < 18 or edge_detail < 8:
                raise serializers.ValidationError(
                    "Foto wajah buram atau kurang jelas. Bersihkan kamera dan ambil foto ulang."
                )
    finally:
        image.seek(0)
    return image


class FaceDataSerializer(serializers.ModelSerializer):

    employee_name = serializers.CharField(
        source="employee.nama",
        read_only=True
    )

    class Meta:
        model = FaceData
        fields = "__all__"


class RegisterFaceSerializer(serializers.Serializer):

    image = serializers.ImageField(validators=[validate_face_image])

class VerifyFaceSerializer(serializers.Serializer):

    image = serializers.ImageField(validators=[validate_face_image])
