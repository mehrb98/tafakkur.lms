import '../../widgets/hero_widgets.dart';

// Sample data for widgets the Rails API has no endpoint for yet (attendance
// aggregates, timetable, homework, exams). Mirrors
// `frontend/src/features/dashboard/data/mock.ts`.

enum ScheduleStatus { done, now, next }

class ScheduleEntry {
  const ScheduleEntry(this.time, this.title, this.subtitle, {this.room, this.status});

  final String time;
  final String title;
  final String subtitle;
  final String? room;
  final ScheduleStatus? status;
}

class TaskEntry {
  const TaskEntry(this.title, this.subtitle, this.due, this.tone);

  final String title;
  final String subtitle;
  final String due;
  final Tone tone;
}

class ChildSummary {
  const ChildSummary(this.name, this.className, this.average, this.attendance, this.homeworkDue);

  final String name;
  final String className;
  final double average;
  final int attendance;
  final int homeworkDue;
}

const weeklyAttendance = <(String, double)>[
  ('Mon', 94),
  ('Tue', 96),
  ('Wed', 91),
  ('Thu', 95),
  ('Fri', 89),
  ('Sat', 92),
];

const gradeDistribution = <(String, double)>[('5 (A)', 142), ('4 (B)', 218), ('3 (C)', 121), ('2 (D)', 34)];

const subjectScores = <(String, double)>[
  ('Math', 88),
  ('Physics', 76),
  ('English', 92),
  ('History', 81),
  ('Biology', 70),
  ('Uzbek', 95),
];

const upcomingEvents = [
  ScheduleEntry('Mon, 09:00', 'Parent–teacher meeting', 'Grades 5–7 · Assembly hall'),
  ScheduleEntry('Wed, 14:00', 'Mid-term exams begin', 'All grades'),
  ScheduleEntry('Fri, 11:30', 'Science fair', 'Grades 8–11 · Gym'),
  ScheduleEntry('Sat, 10:00', 'Staff training', 'Teachers · Room 204'),
];

const teacherSchedule = [
  ScheduleEntry('08:30', 'Algebra', 'Grade 9-A', room: 'Room 204', status: ScheduleStatus.done),
  ScheduleEntry('09:25', 'Geometry', 'Grade 10-B', room: 'Room 204', status: ScheduleStatus.now),
  ScheduleEntry('11:10', 'Algebra', 'Grade 9-C', room: 'Room 112', status: ScheduleStatus.next),
  ScheduleEntry('13:00', 'Calculus club', 'Grades 10–11', room: 'Room 305'),
];

const teacherTasks = [
  TaskEntry('Grade quiz #4', 'Grade 9-A · 28 submissions', 'Today', Tone.danger),
  TaskEntry('Take attendance', 'Grade 10-B · period 2', 'Now', Tone.warning),
  TaskEntry('Publish homework', 'Grade 9-C · Quadratic equations', 'Tomorrow', Tone.accent),
  TaskEntry('Submit term report', 'Mathematics department', 'Fri', Tone.success),
];

const studentSchedule = [
  ScheduleEntry('08:30', 'Algebra', 'Aziz Rahimov', room: 'Room 204', status: ScheduleStatus.done),
  ScheduleEntry('09:25', 'English', 'Nodira Saidova', room: 'Room 118', status: ScheduleStatus.now),
  ScheduleEntry('10:20', 'Physics', 'Bekzod Tursunov', room: 'Lab 2', status: ScheduleStatus.next),
  ScheduleEntry('11:10', 'History', 'Gulnora Aliyeva', room: 'Room 109'),
];

const studentHomework = [
  TaskEntry('Quadratic equations, ex. 12–20', 'Algebra', 'Tomorrow', Tone.warning),
  TaskEntry('Essay: My favourite book', 'English', 'Thu', Tone.accent),
  TaskEntry('Lab report: Pendulum', 'Physics', 'Fri', Tone.accent),
  TaskEntry('Chapter 4 questions', 'History', 'Overdue', Tone.danger),
];

const parentChildren = [
  ChildSummary('Malika Yusupova', 'Grade 9-A', 4.6, 97, 2),
  ChildSummary('Jasur Yusupov', 'Grade 5-B', 4.2, 93, 1),
];

const announcements = [
  TaskEntry('Mid-term exam timetable published', 'Administration', '2h ago', Tone.accent),
  TaskEntry('School closed on Monday (holiday)', 'Administration', 'Yesterday', Tone.warning),
  TaskEntry('Science fair registration is open', 'Science department', '3d ago', Tone.success),
];
