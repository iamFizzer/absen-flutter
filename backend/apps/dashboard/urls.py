from django.urls import path

from .views import BusinessIntelligenceView, DashboardView

urlpatterns = [

    path(
        "",
        DashboardView.as_view(),
        name="dashboard",
    ),
    path(
        "business-intelligence/",
        BusinessIntelligenceView.as_view(),
        name="business-intelligence",
    ),

]
