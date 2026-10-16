import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../auth/auth_provider.dart';

class _RolePage extends ConsumerWidget {
  const _RolePage({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title, message;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: headerGradient),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFCCFBF1),
                        child: Icon(icon, size: 40, color: AppColors.primary),
                      ),
                      const SizedBox(height: 20),
                      Text(title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(
                        'Bonjour ${user?.fullName ?? ''}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '',
                          style: const TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 16),
                      Text(message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.muted, height: 1.4)),
                      const SizedBox(height: 28),
                      OutlinedButton.icon(
                        onPressed: () =>
                            ref.read(authProvider.notifier).logout(),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Se déconnecter'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ParticipantPage extends StatelessWidget {
  const ParticipantPage({super.key});

  @override
  Widget build(BuildContext context) => const _RolePage(
    title: 'Espace Bénévole',
    message: 'Les missions et votre historique arriveront ici.',
    icon: Icons.person_rounded,
  );
}

class AssociationPage extends StatelessWidget {
  const AssociationPage({super.key});

  @override
  Widget build(BuildContext context) => const _RolePage(
    title: 'Espace Association',
    message: 'La gestion de vos événements arrivera ici.',
    icon: Icons.apartment_rounded,
  );
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) => const _RolePage(
    title: 'Espace Administrateur',
    message: 'La supervision de la plateforme arrivera ici.',
    icon: Icons.admin_panel_settings_rounded,
  );
}