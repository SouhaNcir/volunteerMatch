from django.contrib.auth.password_validation import validate_password
from django.contrib.auth.tokens import default_token_generator
from django.core.mail import send_mail
from django.core.exceptions import ValidationError
from django.utils.encoding import force_bytes, force_str
from django.utils.http import urlsafe_base64_decode, urlsafe_base64_encode
from rest_framework import generics, permissions, status
from rest_framework.parsers import FormParser, JSONParser, MultiPartParser
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView

from .models import User
from .serializers import (CustomTokenSerializer, RegisterSerializer,
                          UserSerializer)


class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


class LoginView(TokenObtainPairView):
    serializer_class = CustomTokenSerializer


class MeView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [JSONParser, MultiPartParser, FormParser]  # photo/logo

    def get_object(self):
        return self.request.user


class ForgotPasswordView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        email = request.data.get("email", "")
        user = User.objects.filter(email=email, is_active=True).first()
        if user:
            uid = urlsafe_base64_encode(force_bytes(user.pk))
            token = default_token_generator.make_token(user)
            send_mail(
                "Réinitialisation de votre mot de passe",
                f"uid : {uid}\ntoken : {token}",
                None, [email],
            )
        # Même réponse dans tous les cas (on ne révèle pas si l'e-mail existe)
        return Response({"detail": "Si ce compte existe, un e-mail a été envoyé."})


class ResetPasswordView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        try:
            pk = force_str(urlsafe_base64_decode(request.data.get("uid", "")))
            user = User.objects.get(pk=pk)
        except Exception:
            return Response({"detail": "Lien invalide."}, status=400)

        if not default_token_generator.check_token(user, request.data.get("token", "")):
            return Response({"detail": "Lien invalide ou expiré."}, status=400)

        try:
            validate_password(request.data.get("new_password", ""), user)
        except ValidationError as e:
            return Response({"new_password": e.messages}, status=400)

        user.set_password(request.data["new_password"])
        user.save()
        return Response({"detail": "Mot de passe modifié."})