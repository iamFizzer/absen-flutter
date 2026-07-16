from django.urls import path

from .views import AttendanceSubmitView, AttendanceTodayView

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

]
