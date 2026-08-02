from datetime import time

from django.test import TestCase

from .models import Holiday
from .serializers import HolidaySerializer


class HolidaySerializerTests(TestCase):
    def test_open_attendance_requires_working_hours(self):
        serializer = HolidaySerializer(data={
            "nama": "Uji hari libur",
            "tanggal": "2026-08-17",
            "jenis": "hari_libur",
            "boleh_presensi": True,
            "toleransi_menit": 10,
        })

        self.assertFalse(serializer.is_valid())
        self.assertIn("jam_masuk", serializer.errors)

    def test_open_collective_leave_accepts_custom_working_hours(self):
        serializer = HolidaySerializer(data={
            "nama": "Cuti bersama uji presensi",
            "tanggal": "2026-08-18",
            "jenis": "cuti_bersama",
            "boleh_presensi": True,
            "jam_masuk": "09:00",
            "jam_pulang": "15:00",
            "toleransi_menit": 20,
        })

        self.assertTrue(serializer.is_valid(), serializer.errors)
        holiday = serializer.save()
        self.assertEqual(holiday.jam_masuk, time(9, 0))

    def test_holiday_date_must_be_unique(self):
        Holiday.objects.create(nama="Libur", tanggal="2026-08-19")
        serializer = HolidaySerializer(data={
            "nama": "Libur lain",
            "tanggal": "2026-08-19",
        })

        self.assertFalse(serializer.is_valid())
        self.assertIn("tanggal", serializer.errors)

# Create your tests here.
