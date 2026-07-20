from django.test import SimpleTestCase

from apps.common.utils.geolocation import GeoLocation
from apps.attendance.serializers import AttendanceSubmitSerializer


class GeoLocationTests(SimpleTestCase):
    def test_same_coordinate_is_inside_radius(self):
        result = GeoLocation.check_radius(
            -6.2000000,
            106.8166667,
            -6.2000000,
            106.8166667,
            100,
        )

        self.assertEqual(result["distance"], 0)
        self.assertTrue(result["allowed"])

    def test_distant_coordinate_is_outside_radius(self):
        result = GeoLocation.check_radius(
            -6.2000000,
            106.8166667,
            -6.2100000,
            106.8166667,
            100,
        )

        self.assertGreater(result["distance"], 100)
        self.assertFalse(result["allowed"])


class AttendanceCoordinateSerializerTests(SimpleTestCase):
    def test_coordinate_with_seven_decimal_places_is_valid(self):
        serializer = AttendanceSubmitSerializer(data={
            "latitude": "-6.2000000",
            "longitude": "106.8166667",
        })

        # Selfie diuji terpisah; koordinat tidak boleh menghasilkan error.
        serializer.is_valid()
        self.assertNotIn("latitude", serializer.errors)
        self.assertNotIn("longitude", serializer.errors)

    def test_raw_high_precision_coordinate_is_rejected(self):
        serializer = AttendanceSubmitSerializer(data={
            "latitude": "-6.20000001234567",
            "longitude": "106.81666671234567",
        })

        serializer.is_valid()
        self.assertIn("latitude", serializer.errors)
        self.assertIn("longitude", serializer.errors)

    def test_action_must_be_check_in_or_check_out(self):
        serializer = AttendanceSubmitSerializer(data={
            "action": "check_in_again",
            "latitude": "-6.2000000",
            "longitude": "106.8166667",
        })

        serializer.is_valid()
        self.assertIn("action", serializer.errors)

# Create your tests here.
