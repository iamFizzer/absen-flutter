from django.urls import path

from .views import (
    AttendanceHistoryView,
    AttendanceMonthlyRecapView,
    AttendanceRecapExportView,
    AttendanceSubmitView,
    AttendanceTodayView,
    HolidayAttendanceApprovalDecisionView,
    HolidayAttendanceApprovalListView,
    LeaveRequestDecisionView,
    LeaveRequestDetailView,
    LeaveRequestListCreateView,
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
    path(
        "holiday-approvals/",
        HolidayAttendanceApprovalListView.as_view(),
        name="holiday-attendance-approvals",
    ),
    path(
        "holiday-approvals/<int:attendance_id>/decision/",
        HolidayAttendanceApprovalDecisionView.as_view(),
        name="holiday-attendance-approval-decision",
    ),
    path("leave-requests/", LeaveRequestListCreateView.as_view(), name="leave-requests"),
    path("leave-requests/<int:request_id>/", LeaveRequestDetailView.as_view(), name="leave-request-detail"),
    path("leave-requests/<int:request_id>/decision/", LeaveRequestDecisionView.as_view(), name="leave-request-decision"),

]
