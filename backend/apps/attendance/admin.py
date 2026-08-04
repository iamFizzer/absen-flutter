from django.contrib import admin
from .models import Attendance, LeaveRequest


@admin.register(Attendance)
class AttendanceAdmin(admin.ModelAdmin):

    list_display = (
        "employee",
        "office",
        "tanggal",
        "jam_masuk",
        "jam_pulang",
        "status",
    )

    list_filter = (
        "status",
        "tanggal",
        "office",
    )

    search_fields = (
        "employee__nip",
        "employee__nama",
    )

    autocomplete_fields = (
        "employee",
        "office",
    )

    readonly_fields = (
        "created_at",
    )

    ordering = (
        "-tanggal",
        "-jam_masuk",
    )


@admin.register(LeaveRequest)
class LeaveRequestAdmin(admin.ModelAdmin):
    list_display = ("employee", "type", "start_date", "end_date", "status")
    list_filter = ("type", "status", "start_date")
    search_fields = ("employee__nama", "employee__nip", "reason")
