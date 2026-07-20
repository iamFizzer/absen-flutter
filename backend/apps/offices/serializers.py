from rest_framework import serializers
from .models import Office


class OfficeSerializer(serializers.ModelSerializer):
    last_update = serializers.DateTimeField(source="updated_at", read_only=True)

    class Meta:
        model = Office
        fields = "__all__"
