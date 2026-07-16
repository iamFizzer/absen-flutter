from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .services import AttendanceError, AttendanceService
from .serializers import AttendanceSubmitSerializer, AttendanceTodaySerializer


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


class AttendanceSubmitView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = AttendanceSubmitSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            result = AttendanceService.submit(
                request.user,
                serializer.validated_data["latitude"],
                serializer.validated_data["longitude"],
                serializer.validated_data["selfie"],
            )
        except AttendanceError as exc:
            return Response(
                {"success": False, "message": str(exc)},
                status=400,
            )

        attendance = AttendanceTodaySerializer(result["attendance"]).data
        return Response({
            "success": True,
            "message": result["message"],
            "data": {
                "action": result["action"],
                "distance": result["distance"],
                "face_score": result["face_score"],
                "attendance": attendance,
            },
        })
