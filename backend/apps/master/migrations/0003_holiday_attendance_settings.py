from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("master", "0002_holiday_updated_at_shift_updated_at"),
    ]

    operations = [
        migrations.AddField(
            model_name="holiday",
            name="jenis",
            field=models.CharField(
                choices=[("hari_libur", "Hari Libur"), ("cuti_bersama", "Cuti Bersama")],
                default="hari_libur",
                max_length=20,
            ),
        ),
        migrations.AddField(
            model_name="holiday",
            name="boleh_presensi",
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name="holiday",
            name="jam_masuk",
            field=models.TimeField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="holiday",
            name="jam_pulang",
            field=models.TimeField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="holiday",
            name="toleransi_menit",
            field=models.PositiveIntegerField(default=15),
        ),
        migrations.AddConstraint(
            model_name="holiday",
            constraint=models.UniqueConstraint(fields=("tanggal",), name="unique_holiday_date"),
        ),
    ]
