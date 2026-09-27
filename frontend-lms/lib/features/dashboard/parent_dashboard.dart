import 'package:flutter/material.dart';

import '../../app/theme/hero_colors.dart';
import '../../widgets/charts.dart';
import '../../widgets/hero_widgets.dart';
import '../../widgets/lists.dart';
import 'mock_data.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBody(
      children: [
        const PageHeader(title: 'My children', description: 'Grades, attendance and homework for each child.'),
        ResponsiveGrid(
          columns: 2,
          minItemWidth: 320,
          children: [for (final child in parentChildren) _ChildCard(child)],
        ),
        gap,
        const ResponsiveGrid(
          columns: 3,
          minItemWidth: 320,
          spans: [2, 1],
          children: [
            HeroCard(
              title: 'Attendance',
              description: 'This week',
              action: SampleChip(),
              child: AttendanceChart(weeklyAttendance),
            ),
            HeroCard(title: 'School announcements', action: SampleChip(), child: TaskList(announcements)),
          ],
        ),
      ],
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard(this.child);

  final ChildSummary child;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    final initials = child.name.split(' ').map((part) => part[0]).join();
    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HeroAvatar(initials, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(child.className, style: TextStyle(fontSize: 14, color: hero.muted)),
                  ],
                ),
              ),
              if (child.homeworkDue > 0) HeroChip('${child.homeworkDue} due', tone: Tone.warning),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Average grade', style: TextStyle(fontSize: 12, color: hero.muted)),
                    Text(
                      child.average.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Attendance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        Text('${child.attendance}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: child.attendance / 100,
                        minHeight: 4,
                        color: hero.success,
                        backgroundColor: hero.defaultColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
