import 'package:flutter/material.dart';
import '../models/user.dart';
import 'theme.dart';

void showSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? AppColors.danger : AppColors.primaryDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
}

BoxDecoration cardDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: AppColors.border),
  boxShadow: const [
    BoxShadow(color: Color(0x0F0F172A), blurRadius: 16, offset: Offset(0, 6)),
  ],
);

const headerGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.primaryDark, AppColors.primary],
);
class AppUser {
  final int id;
  final String email, firstName, lastName, role;
  final String phone, city, description, website;
  final String birthDate, skills, organizationName, address;
  final String registrationNumber, domains;
  final bool isApproved;

  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.phone,
    required this.city,
    required this.description,
    required this.website,
    required this.birthDate,
    required this.skills,
    required this.organizationName,
    required this.address,
    required this.registrationNumber,
    required this.domains,
    required this.isApproved,
  });

  factory AppUser.fromJson(dynamic j) => AppUser(
    id: j['id'],
    email: j['email'] ?? '',
    firstName: j['first_name'] ?? '',
    lastName: j['last_name'] ?? '',
    role: j['role'] ?? 'participant',
    phone: j['phone'] ?? '',
    city: j['city'] ?? '',
    description: j['description'] ?? '',
    website: j['website'] ?? '',
    birthDate: j['birth_date'] ?? '',
    skills: j['skills'] ?? '',
    organizationName: j['organization_name'] ?? '',
    address: j['address'] ?? '',
    registrationNumber: j['registration_number'] ?? '',
    domains: j['domains'] ?? '',
    isApproved: j['is_approved'] ?? true,
  );

  bool get isAssociation => role == 'association';
  bool get isAdmin => role == 'admin';

  String get fullName {
    final n = '$firstName $lastName'.trim();
    return n.isEmpty ? email : n;
  }

  /// Nom affiché : le nom de l'association, sinon le nom de la personne.
  String get displayName =>
      (isAssociation && organizationName.isNotEmpty) ? organizationName : fullName;

  String get initials {
    final src = displayName.trim();
    if (src.isEmpty) return '?';
    final parts = src.split(RegExp(r'\s+'));
    final s = parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'
        : parts[0][0];
    return s.toUpperCase();
  }

  String get roleLabel => switch (role) {
    'association' => 'Association',
    'admin' => 'Administrateur',
    _ => 'Bénévole',
  };
}
class Validators {
  static String? required(String? v, [String label = 'Ce champ']) =>
      (v == null || v.trim().isEmpty) ? '$label est obligatoire' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return "L'e-mail est obligatoire";
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Adresse e-mail invalide';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Le mot de passe est obligatoire';
    if (v.length < 8) return 'Au moins 8 caractères';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return RegExp(r'^\+?[0-9 ]{8,15}$').hasMatch(v.trim())
        ? null
        : 'Numéro de téléphone invalide';
  }

  static String? url(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final uri = Uri.tryParse(v.trim());
    final ok = uri != null && uri.hasScheme && uri.host.isNotEmpty;
    return ok ? null : 'Lien invalide (ex. https://exemple.org)';
  }
}

/// Écran d'authentification : bandeau dégradé + feuille blanche arrondie.
/// Écran d'authentification adaptatif : 2 colonnes sur grand écran,
/// bandeau + feuille arrondie sur mobile.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onBack,
  });

  final String title, subtitle;
  final Widget child;
  final VoidCallback? onBack;

  Widget _content(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(subtitle,
            style: t.bodyMedium?.copyWith(color: AppColors.muted)),
        const SizedBox(height: 28),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(body: wide ? _buildWide(context) : _buildNarrow(context));
  }

  // ---------- Grand écran (navigateur) ----------
  Widget _buildWide(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 11, child: _BrandPanel()),
        Expanded(
          flex: 9,
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (onBack != null) ...[
                          TextButton.icon(
                            onPressed: onBack,
                            icon: const Icon(Icons.arrow_back_rounded, size: 18),
                            label: const Text('Retour'),
                          ),
                          const SizedBox(height: 12),
                        ],
                        _content(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Mobile ----------
  Widget _buildNarrow(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: headerGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 24, 28),
              child: Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                    )
                  else
                    const SizedBox(width: 4),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0x26FFFFFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.volunteer_activism_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text('VolunteersMatch',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: _content(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Panneau de gauche (grand écran) : identité de la plateforme.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  Widget _circle(double size, int color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Color(color)),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: headerGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(top: -80, right: -80, child: _circle(260, 0x14FFFFFF)),
          Positioned(bottom: -120, left: -60, child: _circle(340, 0x0FFFFFFF)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0x26FFFFFF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.volunteer_activism_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Text('VolunteersMatch',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'Engagez-vous,\nsimplement.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 46,
                        height: 1.1,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'La plateforme qui relie les associations et les bénévoles '
                        'pour des missions qui comptent.',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 17, height: 1.5),
                  ),
                  const SizedBox(height: 36),
                  const _Feature(Icons.search_rounded,
                      'Trouvez des missions près de chez vous'),
                  const _Feature(Icons.schedule_rounded,
                      'Suivez vos heures de bénévolat'),
                  const _Feature(Icons.workspace_premium_rounded,
                      'Obtenez vos attestations officielles'),
                  const Spacer(),
                  const Text('© 2026 VolunteersMatch',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0x26FFFFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Mot de passe',
    this.validator,
    this.action = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction action;
  final VoidCallback? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      textInputAction: widget.action,
      validator: widget.validator,
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _hidden = !_hidden),
          icon: Icon(_hidden
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
      {super.key,
        required this.label,
        required this.onPressed,
        this.loading = false});

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? () {} : onPressed,
      child: loading
          ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2.4, color: Colors.white))
          : Text(label),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar(
      {super.key, required this.user, this.radius = 28, this.onDark = false});

  final AppUser user;
  final double radius;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor:
      onDark ? const Color(0x33FFFFFF) : const Color(0xFFCCFBF1),
      child: Text(
        user.initials,
        style: TextStyle(
          fontSize: radius * .7,
          fontWeight: FontWeight.w700,
          color: onDark ? Colors.white : AppColors.primaryDark,
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard(
      {super.key,
        required this.icon,
        required this.value,
        required this.label,
        required this.color});

  final IconData icon;
  final String value, label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title, message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFF0FDFA),
            child: Icon(icon, size: 30, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.4)),
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}