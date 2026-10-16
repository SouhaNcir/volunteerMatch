from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (ForgotPasswordView, LoginView, MeView, RegisterView,
                    ResetPasswordView)

urlpatterns = [
    path("auth/register/", RegisterView.as_view()),
    path("auth/login/", LoginView.as_view()),
    path("auth/refresh/", TokenRefreshView.as_view()),
    path("auth/forgot-password/", ForgotPasswordView.as_view()),
    path("auth/reset-password/", ResetPasswordView.as_view()),
    path("users/me/", MeView.as_view()),
]