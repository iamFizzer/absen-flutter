from django.db import models
from apps.employees.models import Employee

class FaceData(models.Model):

    employee = models.OneToOneField(
        Employee,
        on_delete=models.CASCADE,
        related_name="face"
    )

    image = models.ImageField(
        upload_to="faces/"
    )

    encoding = models.JSONField(
        blank=True,
        null=True
    )

    is_active = models.BooleanField(
        default=True
    )

    created_at = models.DateTimeField(
        auto_now_add=True
    )

    updated_at = models.DateTimeField(
        auto_now=True
    )