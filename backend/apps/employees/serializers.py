from django.contrib.auth.models import User
from django.db import transaction
from rest_framework import serializers

from .models import Employee


class EmployeeSerializer(serializers.ModelSerializer):
    last_update = serializers.DateTimeField(source="updated_at", read_only=True)
    username = serializers.CharField(source="user.username")
    password = serializers.CharField(write_only=True, required=False, min_length=6)
    face_registered = serializers.SerializerMethodField()
    face_image = serializers.SerializerMethodField()

    class Meta:
        model = Employee
        fields = [
            "id", "username", "password", "nip", "nama", "jenis_kelamin",
            "tanggal_lahir", "alamat", "telepon", "email", "jabatan",
            "office", "foto", "face_registered", "face_image", "status",
            "created_at", "updated_at", "last_update",
        ]
        read_only_fields = ["created_at", "updated_at"]

    def get_face_registered(self, obj):
        return hasattr(obj, "face") and bool(obj.face.image)

    def get_face_image(self, obj):
        if not hasattr(obj, "face") or not obj.face.image:
            return None
        request = self.context.get("request")
        url = obj.face.image.url
        return request.build_absolute_uri(url) if request else url

    def validate_username(self, value):
        query = User.objects.filter(username=value)
        if self.instance:
            query = query.exclude(pk=self.instance.user_id)
        if query.exists():
            raise serializers.ValidationError("Username sudah digunakan.")
        return value

    @transaction.atomic
    def create(self, validated_data):
        user_data = validated_data.pop("user")
        password = validated_data.pop("password", None)
        if not password:
            raise serializers.ValidationError({"password": "Password wajib diisi."})
        user = User.objects.create_user(
            username=user_data["username"],
            password=password,
            email=validated_data.get("email", ""),
        )
        return Employee.objects.create(user=user, **validated_data)

    @transaction.atomic
    def update(self, instance, validated_data):
        user_data = validated_data.pop("user", None)
        password = validated_data.pop("password", None)
        if user_data:
            instance.user.username = user_data["username"]
        if password:
            instance.user.set_password(password)
        instance.user.email = validated_data.get("email", instance.email)
        instance.user.save()
        return super().update(instance, validated_data)
