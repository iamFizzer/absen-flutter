from django.contrib.auth import authenticate

from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated

from rest_framework_simplejwt.tokens import RefreshToken

from .serializers import LoginSerializer
from .services import AuthService

from apps.common.permissions import IsAdminGroup


class LoginView(APIView):

    permission_classes = []

    def post(self, request):

        serializer = LoginSerializer(
            data=request.data
        )

        serializer.is_valid(
            raise_exception=True
        )

        username = serializer.validated_data["username"]
        password = serializer.validated_data["password"]

        user = authenticate(
            username=username,
            password=password
        )

        if user is None:

            return Response(
                {
                    "success": False,
                    "message": "Username atau password salah."
                },
                status=status.HTTP_401_UNAUTHORIZED
            )

        refresh = RefreshToken.for_user(user)

        groups = list(
            user.groups.values_list(
                "name",
                flat=True
            )
        )

        return Response({

            "success": True,

            "message": "Login berhasil.",

            "access": str(refresh.access_token),

            "refresh": str(refresh),

            "user": {

                "id": user.id,

                "username": user.username,

                "email": user.email,

                "is_active": user.is_active,

                "is_staff": user.is_staff,

                "is_superuser": user.is_superuser,

                "groups": groups,

            }

        })

class ProfileView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):

        data = AuthService.profile(request.user)

        if data is None:

            return Response(
                {
                    "success": False,
                    "message": "Data karyawan tidak ditemukan."
                },
                status=404
            )

        return Response(
            {
                "success": True,
                "message": "Profile berhasil diambil.",
                "data": data
            }
        )