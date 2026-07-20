from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser
from rest_framework.response import Response

from apps.recognition.models import FaceData
from apps.common.exports import excel_response, pdf_response
from apps.recognition.serializers import RegisterFaceSerializer
from .models import Employee
from .serializers import EmployeePasswordSerializer, EmployeeSerializer


class EmployeeViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAdminUser]
    queryset = Employee.objects.select_related("user", "face").order_by(
        "-updated_at", "-id"
    )
    serializer_class = EmployeeSerializer

    @action(detail=True, methods=["post"], url_path="change-password")
    def change_password(self, request, pk=None):
        employee = self.get_object()
        serializer = EmployeePasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        employee.user.set_password(serializer.validated_data["password"])
        employee.user.save(update_fields=["password"])
        return Response(
            {"message": "Password pegawai berhasil diubah."},
            status=status.HTTP_200_OK,
        )

    @action(detail=False, methods=["get"], url_path="export")
    def export(self, request):
        export_format = request.query_params.get("format", "xlsx").lower()
        employees = self.filter_queryset(self.get_queryset())
        headers = ["NIP", "Nama", "Email", "Telepon", "Jabatan", "Kantor", "Status"]
        rows = [
            [item.nip, item.nama, item.email, item.telepon, item.jabatan,
             item.office.nama, item.status]
            for item in employees.select_related("office")
        ]
        if export_format == "pdf":
            return pdf_response("data-pegawai", "Data Pegawai", headers, rows)
        return excel_response("data-pegawai", "Pegawai", headers, rows)

    @action(detail=True, methods=["post"], url_path="face")
    def upload_face(self, request, pk=None):
        serializer = RegisterFaceSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        face, _ = FaceData.objects.get_or_create(employee=self.get_object())
        old_name = face.image.name if face.image else None
        face.image = serializer.validated_data["image"]
        face.encoding = None
        face.is_active = True
        face.save()
        face.employee.save(update_fields=["updated_at"])
        if old_name and old_name != face.image.name:
            face.image.storage.delete(old_name)

        employee_data = EmployeeSerializer(
            face.employee,
            context={"request": request},
        ).data
        return Response(
            {"message": "Foto identifikasi berhasil disimpan.", "employee": employee_data},
            status=status.HTTP_200_OK,
        )
