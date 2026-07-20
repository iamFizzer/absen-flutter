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
