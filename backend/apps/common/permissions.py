from rest_framework.permissions import BasePermission


class IsAdminGroup(BasePermission):

    def has_permission(self, request, view):
        return request.user.groups.filter(name="Admin").exists()


class IsEmployeeGroup(BasePermission):

    def has_permission(self, request, view):
        return request.user.groups.filter(name="Pegawai").exists()