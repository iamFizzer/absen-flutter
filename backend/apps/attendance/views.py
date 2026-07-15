from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .services import AttendanceService
from .serializers import AttendanceTodaySerializer


class AttendanceTodayView(APIView):

    permission_classes = [IsAuthenticated]

    def get(self, request):

        attendance = AttendanceService.today(request.user)

        if attendance is None:
            return Response(
                {
                    "success": False,
                    "message": "Data pegawai tidak ditemukan.",
                },
                status=404,
            )

        serializer = AttendanceTodaySerializer(attendance)

        return Response(
            {
                "success": True,
                "message": "Status presensi berhasil diambil.",
                "data": serializer.data,
            }
        )