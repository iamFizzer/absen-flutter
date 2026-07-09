from django.contrib import admin
from .models import Office


@admin.register(Office)
class OfficeAdmin(admin.ModelAdmin):

    list_display = (
        "nama",
        "radius",
        "status",
    )

    search_fields = (
        "nama",
        "alamat",
    )

    list_filter = (
        "status",
    )