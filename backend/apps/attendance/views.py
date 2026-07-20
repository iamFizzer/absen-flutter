from datetime import datetime, timedelta

from django.utils import timezone
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .services import AttendanceError, AttendanceService
from apps.common.exports import excel_response, pdf_response
from .serializers import (
    AttendanceHistorySerializer,
    AttendanceSubmitSerializer,
    AttendanceTodaySerializer,
)


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
                serializer.validated_data["action"],
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


class AttendanceHistoryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        history = AttendanceService.history(
            request.user,
            _query_int(request, "year"),
            _query_int(request, "month"),
        )
        if history is None:
            return Response(
                {"success": False, "message": "Data pegawai tidak ditemukan."},
                status=404,
            )
        return Response({
            "success": True,
            "data": AttendanceHistorySerializer(history, many=True).data,
        })


class AttendanceMonthlyRecapView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        date_range = _date_range(request)
        data = (
            AttendanceService.recap_by_date(*date_range)
            if date_range
            else AttendanceService.monthly_recap(
                _query_int(request, "year"),
                _query_int(request, "month"),
            )
        )
        return Response({
            "success": True,
            "data": data,
        })


class AttendanceRecapExportView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        date_range = _date_range(request, required=True)
        if date_range is None:
            return Response(
                {"message": "Rentang tanggal tidak valid atau lebih dari 366 hari."},
                status=400,
            )
        start, end = date_range
        recap = AttendanceService.recap_by_date(start, end)
        headers = ["NIP", "Nama", "Hadir", "Terlambat", "Izin", "Sakit", "Cuti", "Alpa"]
        rows = [
            [item["nip"], item["nama"], item["total_hadir"], item["terlambat"],
             item["izin"], item["sakit"], item["cuti"], item["alpa"]]
            for item in recap
        ]
        filename = f"rekap-absensi-{start}-{end}"
        title = f"Rekap Absensi {start:%d/%m/%Y} - {end:%d/%m/%Y}"
        if request.query_params.get("format", "xlsx").lower() == "pdf":
            return pdf_response(filename, title, headers, rows)
        return excel_response(filename, "Rekap Absensi", headers, rows)


def _query_int(request, key):
    value = request.query_params.get(key)
    try:
        return int(value) if value else None
    except ValueError:
        return None


def _date_range(request, required=False):
    start_value = request.query_params.get("start_date")
    end_value = request.query_params.get("end_date")
    if not start_value and not end_value and not required:
        return None
    try:
        start = datetime.strptime(start_value, "%Y-%m-%d").date()
        end = datetime.strptime(end_value, "%Y-%m-%d").date()
    except (TypeError, ValueError):
        return None
    if start > end or end - start > timedelta(days=366):
        return None
    return start, min(end, timezone.localdate())
