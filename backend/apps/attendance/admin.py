from django.contrib import admin
from .models import Attendance


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