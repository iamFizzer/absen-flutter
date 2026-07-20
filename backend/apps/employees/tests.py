from django.contrib.auth.models import User
from django.test import override_settings
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from apps.offices.models import Office

from .models import Employee


@override_settings(MIDDLEWARE=[])
class EmployeeAccountUpdateTests(APITestCase):
    def setUp(self):
        self.admin = User.objects.create_superuser(
            username="admin-test",
            password="AdminPass123!",
        )
        self.user = User.objects.create_user(
            username="pegawai-test",
            password="OldPass123!",
        )
        office = Office.objects.create(
            nama="Kantor Test",
            alamat="Alamat Test",
            latitude="-6.2000000",
            longitude="106.8166667",
            radius=100,
        )
        self.employee = Employee.objects.create(
            user=self.user,
            nip="TEST-001",
            nama="Pegawai Test",
            jenis_kelamin="L",
            tanggal_lahir="2000-01-01",
            alamat="Alamat Test",
            telepon="08123456789",
            email="pegawai@example.com",
            jabatan="Tester",
            office=office,
        )
        self.client.force_authenticate(self.admin)

    def test_regular_update_cannot_change_username_or_password(self):
        response = self.client.patch(
            reverse("employees-detail", args=[self.employee.pk]),
            {"username": "username-baru", "password": "NewPass123!"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.user.refresh_from_db()
        self.assertEqual(self.user.username, "pegawai-test")
        self.assertTrue(self.user.check_password("OldPass123!"))

    def test_change_password_uses_dedicated_endpoint(self):
        response = self.client.post(
            reverse("employees-change-password", args=[self.employee.pk]),
            {
                "password": "NewPass123!",
                "password_confirmation": "NewPass123!",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password("NewPass123!"))

    def test_change_password_requires_matching_confirmation(self):
        response = self.client.post(
            reverse("employees-change-password", args=[self.employee.pk]),
            {
                "password": "NewPass123!",
                "password_confirmation": "Different123!",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password("OldPass123!"))
