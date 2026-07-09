from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated

from .models import Office
from .serializers import OfficeSerializer


class OfficeViewSet(viewsets.ModelViewSet):
    queryset = Office.objects.all()
    serializer_class = OfficeSerializer
