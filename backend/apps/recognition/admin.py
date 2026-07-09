from django.contrib import admin
from .models import FaceData


@admin.register(FaceData)
class FaceDataAdmin(admin.ModelAdmin):

    list_display = (
        "id",
        "employee",
        "created_at",
        "updated_at",
    )

    search_fields = (
        "employee__nama",
        "employee__nip",
    )

    autocomplete_fields = (
        "employee",
    )

    ordering = (
        "-created_at",
    )