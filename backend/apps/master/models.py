from django.db import models


class Shift(models.Model):

    nama = models.CharField(max_length=100)

    jam_masuk = models.TimeField()

    jam_pulang = models.TimeField()

    toleransi_menit = models.IntegerField(default=15)

    aktif = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)

    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "master_shift"

    def __str__(self):
        return self.nama

class Holiday(models.Model):

    JENIS = (
        ("hari_libur", "Hari Libur"),
        ("cuti_bersama", "Cuti Bersama"),
    )

    nama = models.CharField(max_length=150)

    tanggal = models.DateField()

    jenis = models.CharField(max_length=20, choices=JENIS, default="hari_libur")

    boleh_presensi = models.BooleanField(default=False)

    jam_masuk = models.TimeField(null=True, blank=True)

    jam_pulang = models.TimeField(null=True, blank=True)

    toleransi_menit = models.PositiveIntegerField(default=15)

    keterangan = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "master_holiday"
        constraints = [
            models.UniqueConstraint(fields=["tanggal"], name="unique_holiday_date")
        ]

    def __str__(self):
        return self.nama
