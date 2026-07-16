from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("attendance", "0002_attendance_face_score_attendance_updated_at_and_more"),
    ]

    operations = [
        migrations.AddConstraint(
            model_name="attendance",
            constraint=models.UniqueConstraint(
                fields=("employee", "tanggal"),
                name="unique_employee_attendance_date",
            ),
        ),
    ]
