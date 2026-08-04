import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("attendance", "0004_attendance_holiday_approval"),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name="LeaveRequest",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("type", models.CharField(choices=[("cuti", "Cuti"), ("izin", "Izin"), ("sakit", "Sakit")], max_length=10)),
                ("start_date", models.DateField()),
                ("end_date", models.DateField()),
                ("reason", models.TextField()),
                ("attachment", models.FileField(blank=True, null=True, upload_to="leave_requests/")),
                ("status", models.CharField(choices=[("pending", "Menunggu Persetujuan"), ("approved", "Disetujui"), ("rejected", "Ditolak"), ("cancelled", "Dibatalkan")], default="pending", max_length=12)),
                ("decision_note", models.TextField(blank=True)),
                ("decided_at", models.DateTimeField(blank=True, null=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                ("decided_by", models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name="decided_leave_requests", to=settings.AUTH_USER_MODEL)),
                ("employee", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="leave_requests", to="employees.employee")),
            ],
            options={"db_table": "leave_requests", "ordering": ("-created_at",)},
        ),
    ]
