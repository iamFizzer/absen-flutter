from rest_framework import viewsets

from .models import Shift
from .models import Holiday

from .serializers import ShiftSerializer
from .serializers import HolidaySerializer


class ShiftViewSet(viewsets.ReadOnlyModelViewSet):
    
    queryset = Shift.objects.filter(
        aktif=True
    )

    serializer_class = ShiftSerializer


class HolidayViewSet(viewsets.ReadOnlyModelViewSet):

    queryset = Holiday.objects.all()

    serializer_class = HolidaySerializer