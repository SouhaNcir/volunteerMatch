import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_service.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../auth/auth_provider.dart';

class PendingPage extends ConsumerStatefulWidget {
  const PendingPage({super.key});

  @override
  ConsumerState<PendingPage> createState() => _PendingPageState();
}

class _PendingPageState extends ConsumerState<PendingPage> {
  bool _loading = false;

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).refresh();
      final approved = ref.read(authProvider).user?.isApproved ?? false;
      if (mounted && !approved) {
        showSnack(context, "Votre compte n'est pas encore validé.");
      }
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7), shape: BoxShape.circle),
                    child: const Icon(Icons.hourglass_top_rounded,
                        size: 46, color: AppColors.accent),
                  ),
                  const SizedBox(height: 28),
                  const Text('Compte en attente de validation',
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Text(
                    "Merci ${user.firstName}. L'administrateur examine la demande de ${user.email}. "
                        "Vous serez informé dès que votre association sera approuvée.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                      label: 'Actualiser le statut',
                      onPressed: _refresh,
                      loading: _loading),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                    child: const Text('Se déconnecter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}