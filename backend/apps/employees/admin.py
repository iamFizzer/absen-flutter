from django.contrib import admin
from .models import Employee


@admin.register(Employee)
class EmployeeAdmin(admin.ModelAdmin):
    list_display = ('nip', 'nama', 'jabatan', 'status')
    search_fields = ('nip', 'nama')
    list_filter = ('status', 'jabatan')