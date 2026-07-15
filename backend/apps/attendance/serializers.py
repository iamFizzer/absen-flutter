from rest_framework import serializers


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