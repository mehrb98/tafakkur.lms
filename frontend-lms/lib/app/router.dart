import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../core/models/models.dart';
import '../features/auth/login_page.dart';
import '../features/dashboard/admin_dashboard.dart';
import '../features/dashboard/parent_dashboard.dart';
import '../features/dashboard/student_dashboard.dart';
import '../features/dashboard/teacher_dashboard.dart';
import '../features/people/people_page.dart';
import '../features/placeholder/coming_soon_page.dart';
import '../shell/app_shell.dart';

GoRouter buildRouter(AuthController auth) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: auth,
    redirect: (context, state) {
      final user = auth.user;
      final location = state.matchedLocation;
      if (user == null) return location == '/login' ? null : '/login';
      final home = '/${user.role.name}';
      if (location == '/login' || location == '/') return home;
      final section = location.split('/')[1];
      if (Role.tryParse(section) != null && section != user.role.name) return home;
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/admin', builder: (context, state) => const AdminDashboard()),
          GoRoute(
            path: '/admin/students',
            builder: (context, state) => const PeoplePage(kind: PeopleKind.students),
          ),
          GoRoute(
            path: '/admin/teachers',
            builder: (context, state) => const PeoplePage(kind: PeopleKind.teachers),
          ),
          GoRoute(path: '/teacher', builder: (context, state) => const TeacherDashboard()),
          GoRoute(path: '/student', builder: (context, state) => const StudentDashboard()),
          GoRoute(path: '/parent', builder: (context, state) => const ParentDashboard()),
          GoRoute(
            path: '/:role/:section',
            builder: (context, state) => ComingSoonPage(section: state.pathParameters['section']!),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(body: Center(child: Text('Page not found'))),
  );
}
