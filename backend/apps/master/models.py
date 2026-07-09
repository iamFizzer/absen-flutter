from django.db import models


class Shift(models.Model):

    nama = models.CharField(max_length=100)

    jam_masuk = models.TimeField()

    jam_pulang = models.TimeField()

    toleransi_menit = models.IntegerField(default=15)

    aktif = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "master_shift"

    def __str__(self):
        return self.nama

class Holiday(models.Model):

    nama = models.CharField(max_length=150)

    tanggal = models.DateField()

    keterangan = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "master_holiday"

    def __str__(self):
        return self.nama