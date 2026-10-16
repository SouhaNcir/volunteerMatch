class AppUser {
  final int id;
  final String email, firstName, lastName, role;
  final String phone, city, description, website;
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
    isApproved: j['is_approved'] ?? true,
  );

  bool get isAssociation => role == 'association';
  bool get isAdmin => role == 'admin';

  String get fullName {
    final n = '$firstName $lastName'.trim();
    return n.isEmpty ? email : n;
  }

  String get initials {
    final a = firstName.isNotEmpty ? firstName[0] : '';
    final b = lastName.isNotEmpty ? lastName[0] : '';
    final s = '$a$b'.toUpperCase();
    return s.isEmpty ? email[0].toUpperCase() : s;
  }

  String get roleLabel => switch (role) {
    'association' => 'Association',
    'admin' => 'Administrateur',
    _ => 'Bénévole',
  };
}