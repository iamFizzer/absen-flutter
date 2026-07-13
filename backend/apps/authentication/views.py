class ProfileView(APIView):

    permission_classes = [
        IsAuthenticated,
    ]

    def get(self, request):

        profile = AuthService.profile(
            request.user
        )

        if profile is None:

            return Response(
                {
                    "success": False,
                    "message": "Data karyawan tidak ditemukan."
                },
                status=404
            )

        serializer = ProfileSerializer(profile)

        return Response({

            "success": True,

            "message": "Profile berhasil diambil.",

            "data": serializer.data

        })