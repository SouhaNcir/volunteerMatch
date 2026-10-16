from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from .models import User

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = [
            "email", "password", "first_name", "last_name", "role",
            "phone", "city", "birth_date", "skills",
            "organization_name", "address", "registration_number", "domains",
        ]

    def validate_role(self, value):
        if value == User.Role.ADMIN:
            raise serializers.ValidationError("Rôle non autorisé.")
        return value

    def validate_password(self, value):
        validate_password(value)
        return value

    def validate(self, attrs):
        if not attrs.get("city"):
            raise serializers.ValidationError({"city": "La ville est obligatoire."})
        if attrs.get("role") == User.Role.ASSOCIATION:
            if not attrs.get("organization_name"):
                raise serializers.ValidationError(
                    {"organization_name": "Le nom de l'association est obligatoire."})
            if not attrs.get("phone"):
                raise serializers.ValidationError(
                    {"phone": "Le téléphone est obligatoire pour une association."})
        return attrs

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            "id", "email", "first_name", "last_name", "role", "phone", "city",
            "photo", "description", "website", "is_approved",
            "birth_date", "skills", "organization_name", "address",
            "registration_number", "domains",
        ]
        read_only_fields = ["id", "email", "role", "is_approved"]
class CustomTokenSerializer(TokenObtainPairSerializer):
    """Renvoie aussi l'utilisateur (rôle) pour la redirection côté Flutter."""
    def validate(self, attrs):
        data = super().validate(attrs)
        data["user"] = UserSerializer(self.user, context=self.context).data
        return data