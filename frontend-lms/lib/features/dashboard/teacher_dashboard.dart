import 'package:flutter/material.dart';

import '../../widgets/charts.dart';
import '../../widgets/hero_widgets.dart';
import '../../widgets/lists.dart';
import 'mock_data.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageBody(
      children: [
        PageHeader(title: 'Today', description: 'Your lessons, classes and what needs attention.'),
        ResponsiveGrid(
          minItemWidth: 160,
          children: [
            StatCard(label: 'Lessons today', value: '4', icon: Icons.schedule_outlined, hint: 'Next at 11:10'),
            StatCard(
              label: 'My classes',
              value: '6',
              icon: Icons.layers_outlined,
              tone: Tone.success,
              hint: '168 students',
            ),
            StatCard(
              label: 'To grade',
              value: '28',
              icon: Icons.checklist_outlined,
              tone: Tone.warning,
              hint: 'Quiz #4, Grade 9-A',
            ),
            StatCard(
              label: 'Attendance',
              value: '94%',
              icon: Icons.check_circle_outline,
              tone: Tone.danger,
              change: '1.2%',
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
              title: 'Schedule',
              description: "Today's lessons",
              action: SampleChip(),
              child: ScheduleList(teacherSchedule),
            ),
            HeroCard(
              title: 'Class attendance',
              description: 'This week, all your classes',
              action: SampleChip(),
              child: AttendanceChart(weeklyAttendance),
            ),
          ],
        ),
        gap,
        HeroCard(
          title: 'To do',
          description: 'Grading, attendance and homework',
          action: SampleChip(),
          child: TaskList(teacherTasks),
        ),
      ],
    );
  }
}
