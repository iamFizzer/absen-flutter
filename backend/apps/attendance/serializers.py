from rest_framework import serializers

from django.utils import timezone

from .models import Attendance, LeaveRequest


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


class LeaveRequestSerializer(serializers.ModelSerializer):
    employee_name = serializers.CharField(source="employee.nama", read_only=True)
    employee_nip = serializers.CharField(source="employee.nip", read_only=True)
    type_label = serializers.CharField(source="get_type_display", read_only=True)
    status_label = serializers.CharField(source="get_status_display", read_only=True)
    attachment_url = serializers.FileField(source="attachment", read_only=True)
    decided_by_name = serializers.CharField(source="decided_by.username", read_only=True)

    class Meta:
        model = LeaveRequest
        fields = (
            "id", "employee_name", "employee_nip", "type", "type_label",
            "start_date", "end_date", "reason", "attachment", "attachment_url",
            "status", "status_label", "decision_note", "decided_by_name",
            "decided_at", "created_at", "updated_at",
        )
        extra_kwargs = {"attachment": {"write_only": True, "required": False}}
        read_only_fields = ("status", "decision_note", "decided_at")

    def validate(self, attrs):
        start = attrs.get("start_date")
        end = attrs.get("end_date")
        if start and start < timezone.localdate():
            raise serializers.ValidationError({"start_date": "Tanggal mulai tidak boleh sudah berlalu."})
        if start and end and end < start:
            raise serializers.ValidationError({"end_date": "Tanggal selesai tidak boleh sebelum tanggal mulai."})
        if start and end and (end - start).days > 30:
            raise serializers.ValidationError({"end_date": "Maksimal satu pengajuan adalah 31 hari kalender."})
        employee = self.context.get("employee")
        if employee and start and end and LeaveRequest.objects.filter(
            employee=employee,
            status__in=("pending", "approved"),
            start_date__lte=end,
            end_date__gte=start,
        ).exists():
            raise serializers.ValidationError("Sudah ada pengajuan aktif pada rentang tanggal tersebut.")
        return attrs

    def validate_attachment(self, value):
        if value.size > 5 * 1024 * 1024:
            raise serializers.ValidationError("Ukuran lampiran maksimal 5 MB.")
        extension = value.name.rsplit(".", 1)[-1].lower() if "." in value.name else ""
        if extension not in ("jpg", "jpeg", "png", "pdf"):
            raise serializers.ValidationError("Lampiran harus berupa JPG, PNG, atau PDF.")
        return value


class LeaveDecisionSerializer(serializers.Serializer):
    decision = serializers.ChoiceField(choices=("approved", "rejected"))
    note = serializers.CharField(required=False, allow_blank=True, max_length=500)

    def validate(self, attrs):
        if attrs["decision"] == "rejected" and not attrs.get("note", "").strip():
            raise serializers.ValidationError({"note": "Alasan penolakan wajib diisi."})
        return attrs
