from rest_framework import serializers

from .models import Attendance


class AttendanceSubmitSerializer(serializers.Serializer):
    action = serializers.ChoiceField(choices=("check_in", "check_out"))
    latitude = serializers.DecimalField(max_digits=10, decimal_places=7)
    longitude = serializers.DecimalField(max_digits=10, decimal_places=7)
    selfie = serializers.ImageField()


class AttendanceTodaySerializer(serializers.Serializer):

    tanggal = serializers.DateField()

    office = serializers.CharField()

    office_latitude = serializers.FloatField()

    office_longitude = serializers.FloatField()

    radius = serializers.IntegerField()

    jam_masuk = serializers.TimeField(
        allow_null=True
    )

    jam_pulang = serializers.TimeField(
        allow_null=True
    )

    check_in = serializers.TimeField(
        allow_null=True
    )

    check_out = serializers.TimeField(
        allow_null=True
    )

    status = serializers.CharField()

    presensi_dibuka = serializers.BooleanField()

    jenis_hari = serializers.CharField()

    informasi_hari = serializers.CharField(allow_null=True)


class AttendanceHistorySerializer(serializers.Serializer):
    tanggal = serializers.DateField()
    check_in = serializers.TimeField(allow_null=True, format="%H:%M")
    check_out = serializers.TimeField(allow_null=True, format="%H:%M")
    status = serializers.CharField()
    catatan = serializers.CharField(allow_null=True, allow_blank=True)


class HolidayAttendanceApprovalSerializer(serializers.ModelSerializer):
    employee_name = serializers.CharField(source="employee.nama", read_only=True)
    employee_nip = serializers.CharField(source="employee.nip", read_only=True)
    office_name = serializers.CharField(source="office.nama", read_only=True)
    selfie_url = serializers.ImageField(source="selfie", read_only=True)
    approved_by_name = serializers.CharField(
        source="holiday_approved_by.username",
        read_only=True,
        allow_null=True,
    )

    class Meta:
        model = Attendance
        fields = (
            "id",
            "employee_name",
            "employee_nip",
            "office_name",
            "tanggal",
            "jam_masuk",
            "jam_pulang",
            "status",
            "jarak",
            "face_score",
            "selfie_url",
            "holiday_approval_status",
            "holiday_approval_note",
            "approved_by_name",
            "holiday_approved_at",
            "created_at",
        )


class HolidayAttendanceDecisionSerializer(serializers.Serializer):
    decision = serializers.ChoiceField(choices=("approved", "rejected"))
    note = serializers.CharField(required=False, allow_blank=True, max_length=500)
