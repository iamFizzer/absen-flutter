from rest_framework.routers import DefaultRouter
from .views import OfficeViewSet

router = DefaultRouter()
router.register("offices", OfficeViewSet)

urlpatterns = router.urls