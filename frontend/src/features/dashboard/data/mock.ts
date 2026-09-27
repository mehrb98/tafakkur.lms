import type {
    AttendancePoint,
    ChildSummary,
    GradeBucket,
    ScheduleEntry,
    SubjectScore,
    TaskEntry,
} from "../types/dashboard.types";

/*
 * Sample data for dashboard widgets that the Rails API has no endpoint for yet
 * (attendance aggregates, timetable, homework, exams). Replace each export with
 * a service call once the endpoint lands.
 */

export const weeklyAttendance: AttendancePoint[] = [
    { day: "Mon", present: 94, absent: 6 },
    { day: "Tue", present: 96, absent: 4 },
    { day: "Wed", present: 91, absent: 9 },
    { day: "Thu", present: 95, absent: 5 },
    { day: "Fri", present: 89, absent: 11 },
    { day: "Sat", present: 92, absent: 8 },
];

export const gradeDistribution: GradeBucket[] = [
    { label: "5 (A)", count: 142 },
    { label: "4 (B)", count: 218 },
    { label: "3 (C)", count: 121 },
    { label: "2 (D)", count: 34 },
];

export const subjectScores: SubjectScore[] = [
    { subject: "Math", score: 88 },
    { subject: "Physics", score: 76 },
    { subject: "English", score: 92 },
    { subject: "History", score: 81 },
    { subject: "Biology", score: 70 },
    { subject: "Uzbek", score: 95 },
];

export const upcomingEvents: ScheduleEntry[] = [
    { id: "e1", time: "Mon, 09:00", title: "Parent–teacher meeting", subtitle: "Grades 5–7 · Assembly hall" },
    { id: "e2", time: "Wed, 14:00", title: "Mid-term exams begin", subtitle: "All grades" },
    { id: "e3", time: "Fri, 11:30", title: "Science fair", subtitle: "Grades 8–11 · Gym" },
    { id: "e4", time: "Sat, 10:00", title: "Staff training", subtitle: "Teachers · Room 204" },
];

export const teacherSchedule: ScheduleEntry[] = [
    { id: "t1", time: "08:30", title: "Algebra", subtitle: "Grade 9-A", room: "Room 204", status: "done" },
    { id: "t2", time: "09:25", title: "Geometry", subtitle: "Grade 10-B", room: "Room 204", status: "now" },
    { id: "t3", time: "11:10", title: "Algebra", subtitle: "Grade 9-C", room: "Room 112", status: "next" },
    { id: "t4", time: "13:00", title: "Calculus club", subtitle: "Grades 10–11", room: "Room 305" },
];

export const teacherTasks: TaskEntry[] = [
    { id: "k1", title: "Grade quiz #4", subtitle: "Grade 9-A · 28 submissions", due: "Today", tone: "danger" },
    { id: "k2", title: "Take attendance", subtitle: "Grade 10-B · period 2", due: "Now", tone: "warning" },
    { id: "k3", title: "Publish homework", subtitle: "Grade 9-C · Quadratic equations", due: "Tomorrow", tone: "accent" },
    { id: "k4", title: "Submit term report", subtitle: "Mathematics department", due: "Fri", tone: "success" },
];

export const studentSchedule: ScheduleEntry[] = [
    { id: "s1", time: "08:30", title: "Algebra", subtitle: "Aziz Rahimov", room: "Room 204", status: "done" },
    { id: "s2", time: "09:25", title: "English", subtitle: "Nodira Saidova", room: "Room 118", status: "now" },
    { id: "s3", time: "10:20", title: "Physics", subtitle: "Bekzod Tursunov", room: "Lab 2", status: "next" },
    { id: "s4", time: "11:10", title: "History", subtitle: "Gulnora Aliyeva", room: "Room 109" },
];

export const studentHomework: TaskEntry[] = [
    { id: "h1", title: "Quadratic equations, ex. 12–20", subtitle: "Algebra", due: "Tomorrow", tone: "warning" },
    { id: "h2", title: "Essay: My favourite book", subtitle: "English", due: "Thu", tone: "accent" },
    { id: "h3", title: "Lab report: Pendulum", subtitle: "Physics", due: "Fri", tone: "accent" },
    { id: "h4", title: "Chapter 4 questions", subtitle: "History", due: "Overdue", tone: "danger" },
];

export const parentChildren: ChildSummary[] = [
    { id: "c1", name: "Malika Yusupova", className: "Grade 9-A", average: 4.6, attendance: 97, homeworkDue: 2 },
    { id: "c2", name: "Jasur Yusupov", className: "Grade 5-B", average: 4.2, attendance: 93, homeworkDue: 1 },
];

export const announcements: TaskEntry[] = [
    { id: "a1", title: "Mid-term exam timetable published", subtitle: "Administration", due: "2h ago", tone: "accent" },
    { id: "a2", title: "School closed on Monday (holiday)", subtitle: "Administration", due: "Yesterday", tone: "warning" },
    { id: "a3", title: "Science fair registration is open", subtitle: "Science department", due: "3d ago", tone: "success" },
];
