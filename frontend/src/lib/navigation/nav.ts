import type { ComponentType, SVGProps } from "react";
import {
    Book,
    BookOpen,
    Briefcase,
    Calendar,
    ChartColumn,
    CircleCheck,
    Clock,
    FileText,
    Gear,
    GraduationCap,
    House,
    Layers,
    ListCheck,
    Megaphone,
    Person,
    PersonWorker,
    Persons,
} from "@gravity-ui/icons";
import type { Role } from "@/types/api";

export type NavIcon = ComponentType<SVGProps<SVGSVGElement>>;

export interface NavItem {
    label: string;
    href: string;
    icon: NavIcon;
    badge?: string;
}

export interface NavSection {
    title?: string;
    items: NavItem[];
}

export const NAVIGATION: Record<Role, NavSection[]> = {
    admin: [
        { items: [{ label: "Dashboard", href: "/admin", icon: House }] },
        {
            title: "People",
            items: [
                { label: "Students", href: "/admin/students", icon: GraduationCap },
                { label: "Teachers", href: "/admin/teachers", icon: PersonWorker },
                { label: "Parents", href: "/admin/parents", icon: Persons },
            ],
        },
        {
            title: "Academics",
            items: [
                { label: "Classes", href: "/admin/classes", icon: Layers },
                { label: "Subjects", href: "/admin/subjects", icon: Book },
                { label: "Departments", href: "/admin/departments", icon: Briefcase },
                { label: "Academic years", href: "/admin/academic-years", icon: Calendar },
            ],
        },
        {
            title: "School",
            items: [
                { label: "Announcements", href: "/admin/announcements", icon: Megaphone },
                { label: "Reports", href: "/admin/reports", icon: ChartColumn },
                { label: "Settings", href: "/admin/settings", icon: Gear },
            ],
        },
    ],
    teacher: [
        { items: [{ label: "Dashboard", href: "/teacher", icon: House }] },
        {
            title: "Teaching",
            items: [
                { label: "My classes", href: "/teacher/classes", icon: Layers },
                { label: "Lessons", href: "/teacher/lessons", icon: BookOpen },
                { label: "Attendance", href: "/teacher/attendance", icon: CircleCheck },
                { label: "Grades", href: "/teacher/grades", icon: ChartColumn },
            ],
        },
        {
            title: "Assessments",
            items: [
                { label: "Homework", href: "/teacher/homework", icon: ListCheck },
                { label: "Exams", href: "/teacher/exams", icon: FileText },
                { label: "Announcements", href: "/teacher/announcements", icon: Megaphone },
            ],
        },
    ],
    student: [
        { items: [{ label: "Dashboard", href: "/student", icon: House }] },
        {
            title: "Learning",
            items: [
                { label: "Timetable", href: "/student/timetable", icon: Clock },
                { label: "Homework", href: "/student/homework", icon: ListCheck },
                { label: "Exams", href: "/student/exams", icon: FileText },
            ],
        },
        {
            title: "Progress",
            items: [
                { label: "Grades", href: "/student/grades", icon: ChartColumn },
                { label: "Attendance", href: "/student/attendance", icon: CircleCheck },
                { label: "Announcements", href: "/student/announcements", icon: Megaphone },
            ],
        },
    ],
    parent: [
        { items: [{ label: "Dashboard", href: "/parent", icon: House }] },
        {
            title: "Family",
            items: [
                { label: "My children", href: "/parent/children", icon: Person },
                { label: "Grades", href: "/parent/grades", icon: ChartColumn },
                { label: "Attendance", href: "/parent/attendance", icon: CircleCheck },
                { label: "Homework", href: "/parent/homework", icon: ListCheck },
                { label: "Announcements", href: "/parent/announcements", icon: Megaphone },
            ],
        },
    ],
};

export const ROLE_LABELS: Record<Role, string> = {
    admin: "Administrator",
    teacher: "Teacher",
    student: "Student",
    parent: "Parent",
};

/** The nav item whose href is the longest prefix of the current path. */
export function findActiveItem(role: Role, pathname: string): NavItem | undefined {
    return NAVIGATION[role]
        .flatMap((section) => section.items)
        .filter((item) => pathname === item.href || pathname.startsWith(`${item.href}/`))
        .sort((a, b) => b.href.length - a.href.length)[0];
}
