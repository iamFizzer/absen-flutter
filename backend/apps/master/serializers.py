from rest_framework import serializers

from .models import Shift
from .models import Holiday


class ShiftSerializer(serializers.ModelSerializer):
    last_update = serializers.DateTimeField(source="updated_at", read_only=True)

    class Meta:

        model = Shift

        fields = "__all__"


class HolidaySerializer(serializers.ModelSerializer):
    last_update = serializers.DateTimeField(source="updated_at", read_only=True)

    class Meta:

        model = Holiday

        fields = "__all__"

    def validate(self, attrs):
        instance = self.instance
        boleh_presensi = attrs.get(
            "boleh_presensi",
            instance.boleh_presensi if instance else False,
        )
        jam_masuk = attrs.get("jam_masuk", instance.jam_masuk if instance else None)
        jam_pulang = attrs.get("jam_pulang", instance.jam_pulang if instance else None)
        if boleh_presensi and (jam_masuk is None or jam_pulang is None):
            raise serializers.ValidationError({
                "jam_masuk": "Jam masuk dan jam pulang wajib diisi saat presensi diizinkan."
            })
        if jam_masuk and jam_pulang and jam_masuk >= jam_pulang:
            raise serializers.ValidationError({
                "jam_pulang": "Jam pulang harus lebih akhir dari jam masuk."
            })
        return attrs
