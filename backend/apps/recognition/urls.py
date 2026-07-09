from django.urls import path

from .views import (
    RegisterFaceView,
    VerifyFaceView,
)

urlpatterns = [

    path(
        "register-face/",
        RegisterFaceView.as_view(),
    ),

    path(
        "verify-face/",
        VerifyFaceView.as_view(),
    ),

]