export interface AttendancePoint {
    day: string;
    present: number;
    absent: number;
}

export interface GradeBucket {
    label: string;
    count: number;
}

export interface SubjectScore {
    subject: string;
    score: number;
}

export interface ScheduleEntry {
    id: string;
    time: string;
    title: string;
    subtitle: string;
    room?: string;
    status?: "done" | "now" | "next";
}

export interface TaskEntry {
    id: string;
    title: string;
    subtitle: string;
    due: string;
    tone: "accent" | "success" | "warning" | "danger";
}

export interface ChildSummary {
    id: string;
    name: string;
    className: string;
    average: number;
    attendance: number;
    homeworkDue: number;
}
