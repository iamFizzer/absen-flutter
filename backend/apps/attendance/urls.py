from django.urls import path

from .views import (
    AttendanceHistoryView,
    AttendanceMonthlyRecapView,
    AttendanceRecapExportView,
    AttendanceSubmitView,
    AttendanceTodayView,
)

urlpatterns = [

    path(

        "today/",

        AttendanceTodayView.as_view(),

        name="attendance-today",

    ),

    path(
        "submit/",
        AttendanceSubmitView.as_view(),
        name="attendance-submit",
    ),

    path("history/", AttendanceHistoryView.as_view(), name="attendance-history"),
    path(
        "monthly-recap/",
        AttendanceMonthlyRecapView.as_view(),
        name="attendance-monthly-recap",
    ),
    path(
        "recap/export/",
        AttendanceRecapExportView.as_view(),
        name="attendance-recap-export",
    ),

]
