from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet
from rest_framework.generics import ListAPIView

from .models import Attendance
from .serializers import (
    AttendanceSerializer,
    CheckInSerializer,
    AttendanceHistorySerializer
)
from .services import AttendanceService


class AttendanceViewSet(ModelViewSet):

    queryset = Attendance.objects.all()

    serializer_class = AttendanceSerializer


class CheckInView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request):

        serializer = CheckInSerializer(
            data=request.data
        )

        serializer.is_valid(
            raise_exception=True
        )

        result = AttendanceService.check_in(

            request.user,

            serializer.validated_data["latitude"],

            serializer.validated_data["longitude"],

            serializer.validated_data["image"]

        )

        if result["success"]:

            return Response(
                result,
                status=status.HTTP_200_OK
            )

        return Response(
            result,
            status=status.HTTP_400_BAD_REQUEST
        )

class CheckOutView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request):

        serializer = CheckOutSerializer(
            data=request.data
        )

        serializer.is_valid(
            raise_exception=True
        )

        result = AttendanceService.check_out(

            request.user,

            serializer.validated_data["latitude"],

            serializer.validated_data["longitude"]

        )

        status_code = (
            status.HTTP_200_OK
            if result["success"]
            else status.HTTP_400_BAD_REQUEST
        )

        return Response(
            result,
            status=status_code
        )

class AttendanceHistoryView(ListAPIView):

    permission_classes = [IsAuthenticated]

    serializer_class = AttendanceHistorySerializer

    def get_queryset(self):

        return AttendanceService.history(
            self.request.user
        )