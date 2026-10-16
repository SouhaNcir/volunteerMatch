from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models


class UserManager(BaseUserManager):
    use_in_migrations = True

    def create_user(self, email, password=None, **extra):
        if not email:
            raise ValueError("L'e-mail est obligatoire.")
        user = self.model(email=self.normalize_email(email), **extra)
        user.set_password(password)
        user.save()
        return user

    def create_superuser(self, email, password=None, **extra):
        extra.setdefault("is_staff", True)
        extra.setdefault("is_superuser", True)
        extra.setdefault("role", "admin")
        return self.create_user(email, password, **extra)


class User(AbstractUser):
    class Role(models.TextChoices):
        PARTICIPANT = "participant", "Participant"
        ASSOCIATION = "association", "Association"
        ADMIN = "admin", "Administrateur"

    username = None
    email = models.EmailField(unique=True)
    role = models.CharField(max_length=20, choices=Role.choices,
                            default=Role.PARTICIPANT)
    phone = models.CharField(max_length=20, blank=True)
    city = models.CharField(max_length=100, blank=True)
    photo = models.ImageField(upload_to="photos/", blank=True, null=True)
    # Spécifique aux associations
    description = models.TextField(blank=True)
    website = models.URLField(blank=True)
    is_approved = models.BooleanField(default=True)
        # Bénévole
    birth_date = models.DateField(null=True, blank=True)
    skills = models.CharField(max_length=255, blank=True)
    # Association
    organization_name = models.CharField(max_length=150, blank=True)
    address = models.CharField(max_length=255, blank=True)
    registration_number = models.CharField(max_length=50, blank=True)
    domains = models.CharField(max_length=255, blank=True)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = []
    objects = UserManager()

    def save(self, *args, **kwargs):
        # Une association doit être validée par l'administrateur
        if self._state.adding and self.role == self.Role.ASSOCIATION:
            self.is_approved = False
        super().save(*args, **kwargs)

    def __str__(self):
        return self.email