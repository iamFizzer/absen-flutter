from django.urls import path

from .views import AttendanceTodayView

urlpatterns = [

    path(

        "today/",

        AttendanceTodayView.as_view(),

        name="attendance-today",

    ),

]