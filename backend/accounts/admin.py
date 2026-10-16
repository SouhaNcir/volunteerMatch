from django.contrib import admin
from .models import User


@admin.action(description="Approuver les associations sélectionnées")
def approve(modeladmin, request, queryset):
    queryset.update(is_approved=True)


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ("email", "role", "organization_name", "city", "is_approved", "is_active")
    list_filter = ("role", "is_approved", "is_active")
    search_fields = ("email", "first_name", "last_name")
    actions = [approve]