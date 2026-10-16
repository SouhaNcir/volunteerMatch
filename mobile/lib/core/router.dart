import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/auth_provider.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/auth/splash_page.dart';
import '../features/home/pending_page.dart';
import '../features/home/role_pages.dart';
import '../models/user.dart';

/// Page d'accueil correspondant au rôle de l'utilisateur.
String homeFor(AppUser u) {
  if (u.isAdmin) return '/admin';
  if (u.isAssociation) return u.isApproved ? '/association' : '/pending';
  return '/participant';
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AuthState>(authProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/register';

      if (auth.status == AuthStatus.checking) {
        return loc == '/splash' ? null : '/splash';
      }
      if (auth.status == AuthStatus.signedOut) {
        return isAuthRoute ? null : '/login';
      }

      // Connecté : chaque rôle reste dans son espace
      final target = homeFor(auth.user!);
      return loc == target ? null : target;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/participant', builder: (_, __) => const ParticipantPage()),
      GoRoute(path: '/association', builder: (_, __) => const AssociationPage()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminPage()),
      GoRoute(path: '/pending', builder: (_, __) => const PendingPage()),
    ],
  );
});