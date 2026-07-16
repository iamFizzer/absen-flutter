from rest_framework import viewsets
from rest_framework.permissions import IsAdminUser

from .models import Employee
from .serializers import EmployeeSerializer


class EmployeeViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAdminUser]
    queryset = Employee.objects.all()
    serializer_class = EmployeeSerializer
