from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .serializers import (
    RegisterFaceSerializer,
    VerifyFaceSerializer,
)
from .services import RecognitionService


class RegisterFaceView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request):

        serializer = RegisterFaceSerializer(
            data=request.data
        )

        serializer.is_valid(
            raise_exception=True
        )

        result = RecognitionService.register_face(
            request.user,
            serializer.validated_data["image"]
        )

        return Response(
            result,
            status=status.HTTP_200_OK
        )

class VerifyFaceView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request):

        serializer = VerifyFaceSerializer(
            data=request.data
        )

        serializer.is_valid(
            raise_exception=True
        )

        result = RecognitionService.verify_face(

            request.user,

            serializer.validated_data["image"]

        )

        return Response(result)