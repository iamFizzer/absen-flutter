from django.db import models


class Office(models.Model):

    nama = models.CharField(max_length=150)

    alamat = models.TextField()

    latitude = models.DecimalField(
        max_digits=10,
        decimal_places=7
    )

    longitude = models.DecimalField(
        max_digits=10,
        decimal_places=7
    )

    radius = models.IntegerField(default=100)

    status = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)

    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "offices"

    def __str__(self):
        return self.nama