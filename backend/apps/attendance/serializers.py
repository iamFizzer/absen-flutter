from rest_framework import serializers
from .models import Attendance


class AttendanceSerializer(serializers.ModelSerializer):

    employee_name = serializers.CharField(
        source="employee.nama",
        read_only=True
    )

    office_name = serializers.CharField(
        source="office.nama",
        read_only=True
    )

    class Meta:
        model = Attendance
        fields = "__all__"

class CheckInSerializer(serializers.Serializer):

    latitude = serializers.DecimalField(
        max_digits=10,
        decimal_places=7
    )

    longitude = serializers.DecimalField(
        max_digits=10,
        decimal_places=7
    )

    image = serializers.ImageField()

class AttendanceHistorySerializer(serializers.ModelSerializer):

    office = serializers.CharField(
        source="office.nama",
        read_only=True
    )

    class Meta:

        model = Attendance

        fields = (

            "id",

            "tanggal",

            "jam_masuk",

            "jam_pulang",

            "status",

            "jarak",

            "office",

            "catatan",

        )