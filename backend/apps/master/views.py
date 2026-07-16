from rest_framework import viewsets
from rest_framework.permissions import IsAdminUser

from .models import Shift
from .models import Holiday

from .serializers import ShiftSerializer
from .serializers import HolidaySerializer


class ShiftViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAdminUser]
    
    queryset = Shift.objects.filter(
        aktif=True
    )

    serializer_class = ShiftSerializer


class HolidayViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAdminUser]

    queryset = Holiday.objects.all()

    serializer_class = HolidaySerializer
