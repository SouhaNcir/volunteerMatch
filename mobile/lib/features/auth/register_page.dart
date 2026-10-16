import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_service.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _birth = TextEditingController();
  final _skills = TextEditingController();
  final _orgName = TextEditingController();
  final _address = TextEditingController();
  final _regNumber = TextEditingController();
  final _domains = TextEditingController();

  String _role = 'participant';
  DateTime? _birthDate;
  bool _loading = false;

  bool get _isAssociation => _role == 'association';

  @override
  void dispose() {
    for (final c in [
      _first, _last, _email, _password, _confirm, _phone, _city,
      _birth, _skills, _orgName, _address, _regNumber, _domains,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birth.text =
        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = <String, dynamic>{
      'first_name': _first.text.trim(),
      'last_name': _last.text.trim(),
      'email': _email.text.trim(),
      'password': _password.text,
      'role': _role,
      'phone': _phone.text.trim(),
      'city': _city.text.trim(),
      if (_isAssociation) ...{
        'organization_name': _orgName.text.trim(),
        'address': _address.text.trim(),
        'registration_number': _regNumber.text.trim(),
        'domains': _domains.text.trim(),
      } else ...{
        'skills': _skills.text.trim(),
        if (_birthDate != null)
          'birth_date':
          '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
      },
    };

    try {
      await ref.read(authProvider.notifier).register(data);
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
  );

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Créer un compte',
      subtitle: 'Rejoignez la communauté et engagez-vous près de chez vous.',
      onBack: () => context.go('/login'),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Je suis',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _RoleCard(
                    icon: Icons.person_rounded,
                    title: 'Bénévole',
                    subtitle: 'Je cherche des missions',
                    selected: !_isAssociation,
                    onTap: () => setState(() => _role = 'participant'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RoleCard(
                    icon: Icons.apartment_rounded,
                    title: 'Association',
                    subtitle: 'Je publie des événements',
                    selected: _isAssociation,
                    onTap: () => setState(() => _role = 'association'),
                  ),
                ),
              ],
            ),
            if (_isAssociation) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 20, color: Color(0xFFB45309)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Votre compte sera examiné par l'administrateur avant d'être activé.",
                        style:
                        TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ---------- Association : informations de la structure ----------
            if (_isAssociation) ...[
              _sectionTitle("Informations de l'association"),
              TextFormField(
                controller: _orgName,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    Validators.required(v, "Le nom de l'association"),
                decoration: const InputDecoration(
                  labelText: "Nom de l'association",
                  prefixIcon: Icon(Icons.apartment_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regNumber,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "N° d'enregistrement (facultatif)",
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _domains,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "Domaines d'action (ex. santé, environnement)",
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _address,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Adresse (facultatif)',
                  prefixIcon: Icon(Icons.home_work_outlined),
                ),
              ),
            ],

            // ---------- Identité ----------
            _sectionTitle(
                _isAssociation ? 'Responsable du compte' : 'Mes informations'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _first,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => Validators.required(v, 'Le prénom'),
                    decoration: const InputDecoration(labelText: 'Prénom'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _last,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => Validators.required(v, 'Le nom'),
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _city,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => Validators.required(v, 'La ville'),
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (_isAssociation &&
                          (v == null || v.trim().isEmpty)) {
                        return 'Le téléphone est obligatoire';
                      }
                      return Validators.phone(v);
                    },
                    decoration: InputDecoration(
                      labelText:
                      _isAssociation ? 'Téléphone' : 'Téléphone (facultatif)',
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                  ),
                ),
              ],
            ),

            // ---------- Bénévole : informations complémentaires ----------
            if (!_isAssociation) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _birth,
                readOnly: true,
                onTap: _pickBirthDate,
                decoration: const InputDecoration(
                  labelText: 'Date de naissance (facultatif)',
                  prefixIcon: Icon(Icons.cake_outlined),
                  suffixIcon: Icon(Icons.calendar_month_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skills,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Compétences (ex. secourisme, cuisine)',
                  prefixIcon: Icon(Icons.lightbulb_outline_rounded),
                ),
              ),
            ],

            // ---------- Accès ----------
            _sectionTitle('Accès au compte'),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
              decoration: const InputDecoration(
                labelText: 'Adresse e-mail',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: 16),
            PasswordField(
                controller: _password, validator: Validators.password),
            const SizedBox(height: 16),
            PasswordField(
              controller: _confirm,
              label: 'Confirmer le mot de passe',
              action: TextInputAction.done,
              onSubmitted: _submit,
              validator: (v) => v != _password.text
                  ? 'Les mots de passe ne correspondent pas'
                  : null,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
                label: 'Créer mon compte',
                onPressed: _submit,
                loading: _loading),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Déjà un compte ?',
                    style: TextStyle(color: AppColors.muted)),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Se connecter',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title, subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0FDFA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon,
                    color: selected ? AppColors.primary : AppColors.muted),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
