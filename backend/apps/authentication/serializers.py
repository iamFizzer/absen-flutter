from rest_framework import serializers


class LoginSerializer(serializers.Serializer):

    username = serializers.CharField()

    password = serializers.CharField(
        write_only=True
    )


class ProfileSerializer(serializers.Serializer):

    id = serializers.IntegerField()

    username = serializers.CharField()

    email = serializers.EmailField()

    role = serializers.CharField()

    employee_id = serializers.IntegerField()

    nip = serializers.CharField()

    nama = serializers.CharField()

    jabatan = serializers.CharField()

    jenis_kelamin = serializers.CharField()

    telepon = serializers.CharField()

    employee_email = serializers.EmailField(
        allow_null=True,
        required=False
    )

    status = serializers.CharField()

    foto = serializers.CharField(
        allow_null=True,
        required=False
    )