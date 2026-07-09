from django.db import models
from django.contrib.auth.models import User
from apps.offices.models import Office

class Employee(models.Model):

    GENDER = (
        ('L', 'Laki-laki'),
        ('P', 'Perempuan'),
    )

    STATUS = (
        ('aktif', 'Aktif'),
        ('nonaktif', 'Non Aktif'),
    )

    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="employee"
    )

    nip = models.CharField(max_length=30, unique=True)
    nama = models.CharField(max_length=150)
    jenis_kelamin = models.CharField(max_length=1, choices=GENDER)
    tanggal_lahir = models.DateField()

    alamat = models.TextField()

    telepon = models.CharField(max_length=20)

    email = models.EmailField()

    jabatan = models.CharField(max_length=100)
    
    office = models.ForeignKey(
    Office,
    on_delete=models.CASCADE,
    related_name="employees"
)

    foto = models.ImageField(
        upload_to="employees/",
        blank=True,
        null=True
    )

    status = models.CharField(
        max_length=20,
        choices=STATUS,
        default="aktif"
    )

    created_at = models.DateTimeField(auto_now_add=True)

    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "employees"

    def __str__(self):
        return self.nama