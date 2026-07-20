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
