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