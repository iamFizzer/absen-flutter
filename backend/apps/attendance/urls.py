from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import (
    AttendanceViewSet,
    CheckInView,
    CheckOutView,
    AttendanceHistoryView,
)

router = DefaultRouter()

router.register(
    "",
    AttendanceViewSet,
    basename="attendance"
)

urlpatterns = [

    path(
        "check-in/",
        CheckInView.as_view(),
        name="attendance-check-in"
    ),

    path(
    "check-out/",
    CheckOutView.as_view(),
    name="attendance-check-out"
    ),

    path(
    "history/",
    AttendanceHistoryView.as_view(),
    name="attendance-history"
    ),

]

urlpatterns += router.urls