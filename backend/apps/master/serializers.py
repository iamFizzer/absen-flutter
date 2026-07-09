from rest_framework import serializers

from .models import Shift
from .models import Holiday


class ShiftSerializer(serializers.ModelSerializer):

    class Meta:

        model = Shift

        fields = "__all__"


class HolidaySerializer(serializers.ModelSerializer):

    class Meta:

        model = Holiday

        fields = "__all__"