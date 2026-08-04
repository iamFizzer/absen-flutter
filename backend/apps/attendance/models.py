from django.db import models

from apps.employees.models import Employee
from apps.offices.models import Office
from django.conf import settings


class Attendance(models.Model):

    HOLIDAY_APPROVAL_STATUS = (
        ("not_required", "Tidak Diperlukan"),
        ("pending", "Menunggu Approval"),
        ("approved", "Disetujui"),
        ("rejected", "Ditolak"),
    )

    STATUS = (
        ("hadir", "Hadir"),
        ("terlambat", "Terlambat"),
        ("izin", "Izin"),
        ("sakit", "Sakit"),
        ("cuti", "Cuti"),
        ("alpa", "Alpa"),
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

    face_score = models.FloatField(
        default=0
    )

    status = models.CharField(
        max_length=20,
        choices=STATUS
    )

    catatan = models.TextField(
        blank=True,
        null=True
    )

    holiday_approval_status = models.CharField(
        max_length=20,
        choices=HOLIDAY_APPROVAL_STATUS,
        default="not_required",
    )

    holiday_approval_note = models.TextField(blank=True, null=True)

    holiday_approved_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        related_name="approved_holiday_attendances",
    )

    holiday_approved_at = models.DateTimeField(blank=True, null=True)

    created_at = models.DateTimeField(
        auto_now_add=True
    )

    updated_at = models.DateTimeField(
        auto_now=True
    )

    class Meta:
        db_table = "attendance"
        constraints = [
            models.UniqueConstraint(
                fields=["employee", "tanggal"],
                name="unique_employee_attendance_date",
            )
        ]

    def __str__(self):
        return f"{self.employee.nama} - {self.tanggal}"


class LeaveRequest(models.Model):
    TYPE_CHOICES = (("cuti", "Cuti"), ("izin", "Izin"), ("sakit", "Sakit"))
    STATUS_CHOICES = (
        ("pending", "Menunggu Persetujuan"),
        ("approved", "Disetujui"),
        ("rejected", "Ditolak"),
        ("cancelled", "Dibatalkan"),
    )

    employee = models.ForeignKey(Employee, on_delete=models.CASCADE, related_name="leave_requests")
    type = models.CharField(max_length=10, choices=TYPE_CHOICES)
    start_date = models.DateField()
    end_date = models.DateField()
    reason = models.TextField()
    attachment = models.FileField(upload_to="leave_requests/", blank=True, null=True)
    status = models.CharField(max_length=12, choices=STATUS_CHOICES, default="pending")
    decision_note = models.TextField(blank=True)
    decided_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        related_name="decided_leave_requests",
    )
    decided_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "leave_requests"
        ordering = ("-created_at",)

    def __str__(self):
        return f"{self.employee.nama} - {self.get_type_display()} ({self.start_date})"
