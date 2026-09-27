import 'dart:math' as math;

import '../models/models.dart';

const _firstNames = [
  'Malika',
  'Jasur',
  'Dilnoza',
  'Sardor',
  'Nodira',
  'Bekzod',
  'Gulnora',
  'Aziz',
  'Madina',
  'Otabek',
  'Kamola',
  'Sherzod',
  'Zarina',
  'Rustam',
  'Laylo',
  'Timur',
];
const _lastNames = [
  'Yusupova',
  'Rahimov',
  'Karimova',
  'Tursunov',
  'Saidova',
  'Aliyev',
  'Nazarova',
  'Ergashev',
  'Qodirova',
  'Mirzayev',
];
const _subjects = [
  'Mathematics',
  'Physics',
  'English',
  'History',
  'Biology',
  'Uzbek language',
  'Chemistry',
  'Computer science',
];

AppUser _person(int index, Role role) {
  final first = _firstNames[index % _firstNames.length];
  final last = _lastNames[(index * 7) % _lastNames.length];
  return AppUser(
    id: 'demo-${role.name}-$index',
    email: '${first.toLowerCase()}.${last.toLowerCase()}$index@demo.tafakkur.uz',
    firstName: first,
    lastName: last,
    role: role,
    phone: '+998 90 ${100 + index * 7 % 900} ${(1000 + index * 37).toString().substring(1)}',
    emailVerified: index % 5 != 0,
  );
}

final demoStudents = List.generate(
  64,
  (i) => Person(
    id: 'demo-student-$i',
    code: 'STU-2026-${(i + 1).toString().padLeft(4, '0')}',
    detail: i.isEven ? 'female' : 'male',
    date: '202${i % 5}-09-01',
    user: _person(i, Role.student),
  ),
);

final demoTeachers = List.generate(
  23,
  (i) => Person(
    id: 'demo-teacher-$i',
    code: 'EMP-${i + 101}',
    detail: _subjects[i % _subjects.length],
    date: '20${12 + i % 12}-08-15',
    user: _person(i + 40, Role.teacher),
  ),
);

PagedList<Person> paginateDemo(List<Person> all, {required int page, required int limit, required String q}) {
  final query = q.trim().toLowerCase();
  final filtered = query.isEmpty
      ? all
      : all
            .where(
              (p) => '${p.user.fullName} ${p.user.email} ${p.code} ${p.detail ?? ''}'.toLowerCase().contains(query),
            )
            .toList();
  final start = math.min((page - 1) * limit, filtered.length);
  return PagedList(
    items: filtered.sublist(start, math.min(start + limit, filtered.length)),
    page: page,
    totalPages: math.max(1, (filtered.length / limit).ceil()),
    total: filtered.length,
  );
}
