import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme/hero_colors.dart';
import '../../core/models/models.dart';
import '../../core/services/school_service.dart';
import '../../widgets/charts.dart';
import '../../widgets/hero_widgets.dart';
import '../../widgets/lists.dart';
import 'mock_data.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<SchoolCounts> _counts;
  late Future<PagedList<Person>> _recent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final school = AppScope.of(context).school;
    _counts = school.counts();
    _recent = school.students(limit: 5);
  }

  String _format(int value) => value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    return PageBody(
      children: [
        const PageHeader(
          title: 'School overview',
          description: 'Headcounts, attendance and academic performance at a glance.',
        ),
        FutureBuilder(
          future: _counts,
          builder: (context, snapshot) {
            final counts = snapshot.data;
            final hint = snapshot.hasError ? "Couldn't reach the API" : null;
            return ResponsiveGrid(
              minItemWidth: 160,
              children: [
                StatCard(
                  label: 'Students',
                  value: counts == null ? null : _format(counts.students),
                  icon: Icons.school_outlined,
                  hint: hint,
                ),
                StatCard(
                  label: 'Teachers',
                  value: counts == null ? null : _format(counts.teachers),
                  icon: Icons.co_present_outlined,
                  tone: Tone.success,
                  hint: hint,
                ),
                StatCard(
                  label: 'Parents',
                  value: counts == null ? null : _format(counts.parents),
                  icon: Icons.people_outline,
                  tone: Tone.warning,
                  hint: hint,
                ),
                StatCard(
                  label: 'Classes',
                  value: counts == null ? null : _format(counts.classes),
                  icon: Icons.layers_outlined,
                  tone: Tone.danger,
                  hint: hint,
                ),
              ],
            );
          },
        ),
        gap,
        ResponsiveGrid(
          columns: 3,
          minItemWidth: 320,
          spans: const [2, 1],
          children: [
            const HeroCard(
              title: 'Attendance this week',
              description: 'Share of students present',
              action: SampleChip(),
              child: AttendanceChart(weeklyAttendance),
            ),
            HeroCard(
              title: 'Grade distribution',
              description: 'Current term, all subjects',
              action: const SampleChip(),
              child: BarsChart(gradeDistribution, label: 'Grades', color: hero.success),
            ),
          ],
        ),
        gap,
        ResponsiveGrid(
          columns: 3,
          minItemWidth: 320,
          spans: const [1, 2],
          children: [
            HeroCard(
              title: 'Recently added students',
              description: 'Newest enrollments',
              child: FutureBuilder(
                future: _recent,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Couldn't load students: ${snapshot.error}", style: TextStyle(color: hero.muted));
                  }
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final student in snapshot.data!.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              HeroAvatar(student.user.initials),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.user.fullName,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                    Text(student.code, style: TextStyle(fontSize: 12, color: hero.muted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () => context.go('/admin/students'),
                        child: const Text('View all students'),
                      ),
                    ],
                  );
                },
              ),
            ),
            const HeroCard(
              title: 'Upcoming events',
              description: 'Next 7 days',
              action: SampleChip(),
              child: ScheduleList(upcomingEvents),
            ),
          ],
        ),
      ],
    );
  }
}
