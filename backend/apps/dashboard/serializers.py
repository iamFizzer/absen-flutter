from rest_framework import serializers


class DashboardSerializer(serializers.Serializer):

    nama = serializers.CharField()

    jabatan = serializers.CharField()

    shift = serializers.CharField()

    jam_masuk = serializers.CharField()

    jam_pulang = serializers.CharField()

    check_in = serializers.CharField(
        allow_null=True,
    )

    check_out = serializers.CharField(
        allow_null=True,
    )

    status = serializers.CharField()

    total_pegawai = serializers.IntegerField()

    total_kantor = serializers.IntegerField()

    total_presensi = serializers.IntegerField()

    total_terlambat = serializers.IntegerField()