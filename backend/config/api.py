from django.urls import include, path
from rest_framework.routers import DefaultRouter

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

from apps.employees.views import EmployeeViewSet
from apps.offices.views import OfficeViewSet
from apps.attendance.views import AttendanceViewSet
from apps.master.views import ShiftViewSet
from apps.master.views import HolidayViewSet

router = DefaultRouter()

router.register(r'employees', EmployeeViewSet, basename='employees')
router.register(r'offices', OfficeViewSet, basename='offices')
router.register(r'attendance', AttendanceViewSet, basename='attendance')
router.register(
    r'master/shifts',
    ShiftViewSet,
    basename='master-shifts'
)

router.register(
    r'master/holidays',
    HolidayViewSet,
    basename='master-holidays'
)

urlpatterns = [

    path(
        "login/",
        TokenObtainPairView.as_view(),
        name="token_obtain_pair",
    ),

    path(
        "refresh/",
        TokenRefreshView.as_view(),
        name="token_refresh",
    ),

    path(
        "auth/",
        include("apps.authentication.urls"),
    ),

    path(
    "dashboard/",
    include("apps.dashboard.urls"),
    ),

    path(
    "recognition/",
    include("apps.recognition.urls"),
    ),
    
    path(
    "attendance/",
    include("apps.attendance.urls"),
    ),

]

urlpatterns += router.urls