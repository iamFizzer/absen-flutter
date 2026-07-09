from django.db import models

from apps.employees.models import Employee

from apps.offices.models import Office


class Attendance(models.Model):

    STATUS = (
        ('hadir', 'Hadir'),
        ('terlambat', 'Terlambat'),
        ('izin', 'Izin'),
        ('sakit', 'Sakit'),
        ('alpa', 'Alpa'),
    )

    employee = models.ForeignKey(
        Employee,
        on_delete=models.CASCADE
    )

    office = models.ForeignKey(
        Office,
        on_delete=models.CASCADE
    )

    tanggal = models.DateField()

    jam_masuk = models.TimeField(
        null=True,
        blank=True
    )

    jam_pulang = models.TimeField(
        null=True,
        blank=True
    )

    latitude = models.DecimalField(
        max_digits=10,
        decimal_places=7
    )

    longitude = models.DecimalField(
        max_digits=10,
        decimal_places=7
    )

    jarak = models.FloatField()

    selfie = models.ImageField(
        upload_to="attendance/"
    )

    status = models.CharField(
        max_length=20,
        choices=STATUS
    )

    catatan = models.TextField(
        blank=True,
        null=True
    )

    created_at = models.DateTimeField(
        auto_now_add=True
    )

    class Meta:
        db_table = "attendance"

    def __str__(self):
        return f"{self.employee.nama} - {self.tanggal}"