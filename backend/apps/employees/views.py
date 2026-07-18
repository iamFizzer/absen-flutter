from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAdminUser
from rest_framework.response import Response

from apps.recognition.models import FaceData
from apps.recognition.serializers import RegisterFaceSerializer
from .models import Employee
from .serializers import EmployeeSerializer


class EmployeeViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAdminUser]
    queryset = Employee.objects.select_related("user", "face").all()
    serializer_class = EmployeeSerializer

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
