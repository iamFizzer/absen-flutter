from django.contrib import admin

from .models import Shift
from .models import Holiday


@admin.register(Shift)
class ShiftAdmin(admin.ModelAdmin):

    list_display = (
        "nama",
        "jam_masuk",
        "jam_pulang",
        "toleransi_menit",
        "aktif",
    )


@admin.register(Holiday)
class HolidayAdmin(admin.ModelAdmin):

    list_display = (
        "nama",
        "tanggal",
    )