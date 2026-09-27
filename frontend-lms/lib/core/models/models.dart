enum Role {
  admin('Administrator'),
  teacher('Teacher'),
  student('Student'),
  parent('Parent');

  const Role(this.label);
  final String label;

  static Role? tryParse(String? value) {
    for (final role in Role.values) {
      if (role.name == value) return role;
    }
    return null;
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phone,
    this.avatarUrl,
    this.emailVerified = false,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    email: json['email'] as String,
    firstName: json['first_name'] as String? ?? '',
    lastName: json['last_name'] as String? ?? '',
    role: Role.tryParse(json['role'] as String?) ?? Role.student,
    phone: json['phone'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    emailVerified: json['email_verified'] as bool? ?? false,
  );

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final Role role;
  final String? phone;
  final String? avatarUrl;
  final bool emailVerified;

  String get fullName => '$firstName $lastName'.trim();
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
}

/// A student or teacher row: the API nests the user under a profile record.
class Person {
  const Person({required this.id, required this.code, required this.user, this.detail, this.date});

  factory Person.studentFromJson(Map<String, dynamic> json) => Person(
    id: json['id'] as String,
    code: json['student_code'] as String? ?? '',
    detail: json['gender'] as String?,
    date: json['admission_date'] as String?,
    user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
  );

  factory Person.teacherFromJson(Map<String, dynamic> json) => Person(
    id: json['id'] as String,
    code: json['employee_code'] as String? ?? '',
    detail: json['specialization'] as String?,
    date: json['hire_date'] as String?,
    user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
  );

  final String id;
  final String code;
  final AppUser user;

  /// Gender for students, specialization for teachers.
  final String? detail;

  /// Admission date for students, hire date for teachers.
  final String? date;
}

class PagedList<T> {
  const PagedList({required this.items, required this.page, required this.totalPages, required this.total});

  final List<T> items;
  final int page;
  final int totalPages;
  final int total;
}
