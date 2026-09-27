import 'package:flutter/material.dart';

import '../../widgets/charts.dart';
import '../../widgets/hero_widgets.dart';
import '../../widgets/lists.dart';
import 'mock_data.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageBody(
      children: [
        PageHeader(title: 'My day', description: "Lessons, homework and how you're doing."),
        ResponsiveGrid(
          minItemWidth: 160,
          children: [
            StatCard(label: 'Average grade', value: '4.6', icon: Icons.bar_chart_outlined, change: '0.2'),
            StatCard(
              label: 'Attendance',
              value: '97%',
              icon: Icons.check_circle_outline,
              tone: Tone.success,
              hint: '2 absences this term',
            ),
            StatCard(
              label: 'Homework due',
              value: '3',
              icon: Icons.checklist_outlined,
              tone: Tone.warning,
              hint: '1 overdue',
            ),
            StatCard(
              label: 'Next exam',
              value: 'Wed',
              icon: Icons.description_outlined,
              tone: Tone.danger,
              hint: 'Algebra mid-term',
            ),
          ],
        ),
        gap,
        ResponsiveGrid(
          columns: 3,
          minItemWidth: 320,
          spans: [1, 2],
          children: [
            HeroCard(
              title: 'Timetable',
              description: 'Today',
              action: SampleChip(),
              child: ScheduleList(studentSchedule),
            ),
            HeroCard(
              title: 'Scores by subject',
              description: 'Current term average',
              action: SampleChip(),
              child: BarsChart(subjectScores, label: 'Score', unit: '%'),
            ),
          ],
        ),
        gap,
        ResponsiveGrid(
          columns: 2,
          minItemWidth: 320,
          children: [
            HeroCard(title: 'Homework', action: SampleChip(), child: TaskList(studentHomework)),
            HeroCard(title: 'Announcements', action: SampleChip(), child: TaskList(announcements)),
          ],
        ),
      ],
    );
  }
}
