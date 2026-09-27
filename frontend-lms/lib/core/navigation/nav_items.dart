import 'package:flutter/material.dart';

import '../models/models.dart';

class NavItem {
  const NavItem(this.label, this.path, this.icon);

  final String label;
  final String path;
  final IconData icon;
}

class NavSection {
  const NavSection(this.items, {this.title});

  final String? title;
  final List<NavItem> items;
}

/// Sidebar items per role; mirrors `frontend/src/lib/navigation/nav.ts`.
const navigation = <Role, List<NavSection>>{
  Role.admin: [
    NavSection([NavItem('Dashboard', '/admin', Icons.home_outlined)]),
    NavSection(title: 'People', [
      NavItem('Students', '/admin/students', Icons.school_outlined),
      NavItem('Teachers', '/admin/teachers', Icons.co_present_outlined),
      NavItem('Parents', '/admin/parents', Icons.people_outline),
    ]),
    NavSection(title: 'Academics', [
      NavItem('Classes', '/admin/classes', Icons.layers_outlined),
      NavItem('Subjects', '/admin/subjects', Icons.menu_book_outlined),
      NavItem('Departments', '/admin/departments', Icons.work_outline),
      NavItem('Academic years', '/admin/academic-years', Icons.calendar_today_outlined),
    ]),
    NavSection(title: 'School', [
      NavItem('Announcements', '/admin/announcements', Icons.campaign_outlined),
      NavItem('Reports', '/admin/reports', Icons.bar_chart_outlined),
      NavItem('Settings', '/admin/settings', Icons.settings_outlined),
    ]),
  ],
  Role.teacher: [
    NavSection([NavItem('Dashboard', '/teacher', Icons.home_outlined)]),
    NavSection(title: 'Teaching', [
      NavItem('My classes', '/teacher/classes', Icons.layers_outlined),
      NavItem('Lessons', '/teacher/lessons', Icons.auto_stories_outlined),
      NavItem('Attendance', '/teacher/attendance', Icons.check_circle_outline),
      NavItem('Grades', '/teacher/grades', Icons.bar_chart_outlined),
    ]),
    NavSection(title: 'Assessments', [
      NavItem('Homework', '/teacher/homework', Icons.checklist_outlined),
      NavItem('Exams', '/teacher/exams', Icons.description_outlined),
      NavItem('Announcements', '/teacher/announcements', Icons.campaign_outlined),
    ]),
  ],
  Role.student: [
    NavSection([NavItem('Dashboard', '/student', Icons.home_outlined)]),
    NavSection(title: 'Learning', [
      NavItem('Timetable', '/student/timetable', Icons.schedule_outlined),
      NavItem('Homework', '/student/homework', Icons.checklist_outlined),
      NavItem('Exams', '/student/exams', Icons.description_outlined),
    ]),
    NavSection(title: 'Progress', [
      NavItem('Grades', '/student/grades', Icons.bar_chart_outlined),
      NavItem('Attendance', '/student/attendance', Icons.check_circle_outline),
      NavItem('Announcements', '/student/announcements', Icons.campaign_outlined),
    ]),
  ],
  Role.parent: [
    NavSection([NavItem('Dashboard', '/parent', Icons.home_outlined)]),
    NavSection(title: 'Family', [
      NavItem('My children', '/parent/children', Icons.person_outline),
      NavItem('Grades', '/parent/grades', Icons.bar_chart_outlined),
      NavItem('Attendance', '/parent/attendance', Icons.check_circle_outline),
      NavItem('Homework', '/parent/homework', Icons.checklist_outlined),
      NavItem('Announcements', '/parent/announcements', Icons.campaign_outlined),
    ]),
  ],
};

/// The nav item whose path is the longest prefix of [location].
NavItem? activeItem(Role role, String location) {
  NavItem? best;
  for (final item in navigation[role]!.expand((section) => section.items)) {
    final matches = location == item.path || location.startsWith('${item.path}/');
    if (matches && (best == null || item.path.length > best.path.length)) best = item;
  }
  return best;
}
