from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from .services import DashboardService


class DashboardView(APIView):

    def get(self, request):

        data = DashboardService.get_dashboard(request.user)

        if data is None:
            return Response(
                {
                    "success": False,
                    "message": "Data karyawan belum tersedia."
                },
                status=status.HTTP_404_NOT_FOUND
            )

        return Response(
            {
                "success": True,
                "message": "Dashboard berhasil dimuat.",
                "data": data
            }
        )