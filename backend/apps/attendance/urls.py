from rest_framework.routers import DefaultRouter
from .views import AttendaceViewSet

router = DefaultRouter()
router.register("attendance", AttendanceViewSet)

urlpatterns = router.urls