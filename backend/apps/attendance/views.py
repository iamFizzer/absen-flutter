from datetime import datetime, timedelta
import logging

from django.utils import timezone
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404

from .services import AttendanceError, AttendanceService
from .models import Attendance
from apps.common.exports import excel_response, pdf_response
from .serializers import (
    AttendanceHistorySerializer,
    AttendanceSubmitSerializer,
    AttendanceTodaySerializer,
    HolidayAttendanceApprovalSerializer,
    HolidayAttendanceDecisionSerializer,
)


logger = logging.getLogger(__name__)


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
        except Exception:
            logger.exception("Attendance submit failed")
            return Response(
                {
                    "success": False,
                    "message": "Presensi gagal diproses. Silakan coba kembali.",
                },
                status=500,
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
        _absolute_face_urls(request, data)
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
        filename = f"rekap-presensi-{start}-{end}"
        title = f"Rekap Presensi {start:%d/%m/%Y} - {end:%d/%m/%Y}"
        if request.query_params.get("format", "xlsx").lower() == "pdf":
            return pdf_response(filename, title, headers, rows)
        return excel_response(filename, "Rekap Presensi", headers, rows)


class HolidayAttendanceApprovalListView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        status_filter = request.query_params.get("status", "pending")
        queryset = Attendance.objects.filter(
            holiday_approval_status__in=("pending", "approved", "rejected")
        ).select_related("employee", "office", "holiday_approved_by")
        if status_filter in ("pending", "approved", "rejected"):
            queryset = queryset.filter(holiday_approval_status=status_filter)
        queryset = queryset.order_by("-tanggal", "-created_at")
        serializer = HolidayAttendanceApprovalSerializer(
            queryset,
            many=True,
            context={"request": request},
        )
        return Response({"success": True, "data": serializer.data})


class HolidayAttendanceApprovalDecisionView(APIView):
    permission_classes = [IsAdminUser]

    def post(self, request, attendance_id):
        serializer = HolidayAttendanceDecisionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        attendance = get_object_or_404(
            Attendance,
            id=attendance_id,
            holiday_approval_status__in=("pending", "approved", "rejected"),
        )
        attendance.holiday_approval_status = serializer.validated_data["decision"]
        attendance.holiday_approval_note = serializer.validated_data.get("note", "")
        attendance.holiday_approved_by = request.user
        attendance.holiday_approved_at = timezone.now()
        attendance.save(update_fields=[
            "holiday_approval_status",
            "holiday_approval_note",
            "holiday_approved_by",
            "holiday_approved_at",
            "updated_at",
        ])
        return Response({
            "success": True,
            "message": (
                "Presensi hari libur disetujui dan masuk ke rekap."
                if attendance.holiday_approval_status == "approved"
                else "Presensi hari libur ditolak dan tidak masuk ke rekap."
            ),
            "data": HolidayAttendanceApprovalSerializer(
                attendance,
                context={"request": request},
            ).data,
        })


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


def _absolute_face_urls(request, rows):
    for row in rows:
        if row.get("face_image"):
            row["face_image"] = request.build_absolute_uri(row["face_image"])
