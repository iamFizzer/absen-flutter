from rest_framework import serializers
from apps.attendance.serializers import AttendanceHistorySerializer


class DashboardSerializer(serializers.Serializer):
    nama = serializers.CharField()
    jabatan = serializers.CharField()
    face_image = serializers.URLField(allow_null=True)
    office = serializers.CharField()
    shift = serializers.CharField()
    jam_masuk = serializers.TimeField(allow_null=True, format="%H:%M")
    jam_pulang = serializers.TimeField(allow_null=True, format="%H:%M")
    check_in = serializers.TimeField(allow_null=True, format="%H:%M")
    check_out = serializers.TimeField(allow_null=True, format="%H:%M")
    status = serializers.CharField()
    hadir_bulan_ini = serializers.IntegerField()
    terlambat_bulan_ini = serializers.IntegerField()
    durasi_kerja_menit = serializers.IntegerField()
    history_bulan_ini = AttendanceHistorySerializer(many=True)


class BusinessIntelligencePeriodSerializer(serializers.Serializer):
    start_date = serializers.DateField()
    end_date = serializers.DateField()
    workdays = serializers.IntegerField()


class BusinessIntelligenceSummarySerializer(serializers.Serializer):
    active_employees = serializers.IntegerField()
    expected_presence = serializers.IntegerField()
    present_count = serializers.IntegerField()
    late_count = serializers.IntegerField()
    absent_count = serializers.IntegerField()
    leave_count = serializers.IntegerField()
    attendance_rate = serializers.FloatField()
    late_rate = serializers.FloatField()
    completion_rate = serializers.FloatField()
    checked_in_today = serializers.IntegerField()
    checked_out_today = serializers.IntegerField()
    not_checked_in_today = serializers.IntegerField()


class BusinessIntelligenceStatusSerializer(serializers.Serializer):
    status = serializers.CharField()
    total = serializers.IntegerField()


class BusinessIntelligenceDailySerializer(serializers.Serializer):
    date = serializers.DateField()
    label = serializers.CharField()
    hadir = serializers.IntegerField()
    terlambat = serializers.IntegerField()
    izin = serializers.IntegerField()
    alpa = serializers.IntegerField()


class BusinessIntelligenceOfficeSerializer(serializers.Serializer):
    office = serializers.CharField()
    employees = serializers.IntegerField()
    hadir = serializers.IntegerField()
    terlambat = serializers.IntegerField()
    attendance_rate = serializers.FloatField()
    late_rate = serializers.FloatField()
    average_face_score = serializers.FloatField()


class BusinessIntelligenceAttentionSerializer(serializers.Serializer):
    employee_id = serializers.IntegerField()
    nama = serializers.CharField()
    jabatan = serializers.CharField()
    office = serializers.CharField()
    hadir = serializers.IntegerField()
    terlambat = serializers.IntegerField()
    alpa = serializers.IntegerField()


class BusinessIntelligenceSerializer(serializers.Serializer):
    period = BusinessIntelligencePeriodSerializer()
    summary = BusinessIntelligenceSummarySerializer()
    status_breakdown = BusinessIntelligenceStatusSerializer(many=True)
    daily_trend = BusinessIntelligenceDailySerializer(many=True)
    office_performance = BusinessIntelligenceOfficeSerializer(many=True)
    attention_list = BusinessIntelligenceAttentionSerializer(many=True)
