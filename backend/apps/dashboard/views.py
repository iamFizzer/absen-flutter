from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .services import DashboardService
from .serializers import DashboardSerializer


class DashboardView(APIView):

    permission_classes = [
        IsAuthenticated,
    ]

    def get(self, request):

        dashboard = DashboardService.dashboard(
            request.user
        )

        if dashboard is None:
            return Response({
                "success": False,
                "message": "Data pegawai tidak ditemukan."
            }, status=404)

        serializer = DashboardSerializer(
            dashboard
        )

        return Response({

            "success": True,

            "message": "Dashboard berhasil diambil.",

            "data": serializer.data

        })
