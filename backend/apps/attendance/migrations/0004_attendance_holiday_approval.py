from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ("attendance", "0003_unique_employee_attendance_date"),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AddField(
            model_name="attendance",
            name="holiday_approval_status",
            field=models.CharField(
                choices=[
                    ("not_required", "Tidak Diperlukan"),
                    ("pending", "Menunggu Approval"),
                    ("approved", "Disetujui"),
                    ("rejected", "Ditolak"),
                ],
                default="not_required",
                max_length=20,
            ),
        ),
        migrations.AddField(
            model_name="attendance",
            name="holiday_approval_note",
            field=models.TextField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="attendance",
            name="holiday_approved_at",
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="attendance",
            name="holiday_approved_by",
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.SET_NULL,
                related_name="approved_holiday_attendances",
                to=settings.AUTH_USER_MODEL,
            ),
        ),
    ]
