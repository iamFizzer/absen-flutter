from rest_framework import serializers
from .models import FaceData


class FaceDataSerializer(serializers.ModelSerializer):

    employee_name = serializers.CharField(
        source="employee.nama",
        read_only=True
    )

    class Meta:
        model = FaceData
        fields = "__all__"


class RegisterFaceSerializer(serializers.Serializer):

    image = serializers.ImageField()

class VerifyFaceSerializer(serializers.Serializer):

    image = serializers.ImageField()