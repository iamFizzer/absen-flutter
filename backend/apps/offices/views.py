from rest_framework import viewsets
from rest_framework.permissions import IsAdminUser

from .models import Office
from .serializers import OfficeSerializer


class OfficeViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAdminUser]
    
    queryset = Office.objects.all()
    serializer_class = OfficeSerializer
