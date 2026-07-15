from django.contrib.auth import authenticate

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from rest_framework_simplejwt.tokens import RefreshToken

from .serializers import LoginSerializer, ProfileSerializer
from .services import AuthService


class LoginView(APIView):

    permission_classes = []

    def post(self, request):

        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        username = serializer.validated_data["username"]
        password = serializer.validated_data["password"]

        user = authenticate(
            username=username,
            password=password
        )

        if not user:
            return Response(
                {
                    "success": False,
                    "message": "Username atau password salah."
                },
                status=status.HTTP_401_UNAUTHORIZED
            )

        refresh = RefreshToken.for_user(user)

        return Response({
            "success": True,
            "message": "Login berhasil",
            "access": str(refresh.access_token),
            "refresh": str(refresh),
        })


class ProfileView(APIView):

    permission_classes = [
        IsAuthenticated,
    ]

    def get(self, request):

        profile = AuthService.profile(request.user)

        if profile is None:
            return Response(
                {
                    "success": False,
                    "message": "Data karyawan tidak ditemukan."
                },
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = ProfileSerializer(profile)

        return Response({
            "success": True,
            "message": "Profile berhasil diambil.",
            "data": serializer.data
        })