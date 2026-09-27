import type { Metadata } from "next";
import { ChartColumn, CircleCheck, FileText, ListCheck } from "@gravity-ui/icons";
import { ChartCard } from "@/components/charts/ChartCard";
import { PageHeader } from "@/components/page-header/PageHeader";
import { StatCard } from "@/components/stat-card/StatCard";
import { BarsChart } from "@/features/dashboard/components/BarsChart";
import { SampleDataChip } from "@/features/dashboard/components/SampleDataChip";
import { ScheduleList } from "@/features/dashboard/components/ScheduleList";
import { TaskList } from "@/features/dashboard/components/TaskList";
import { announcements, studentHomework, studentSchedule, subjectScores } from "@/features/dashboard/data/mock";

export const metadata: Metadata = { title: "Student dashboard" };

export default function StudentDashboardPage() {
    return (
        <div className="flex flex-col gap-6">
            <PageHeader title="My day" description="Lessons, homework and how you're doing." />
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
                <StatCard label="Average grade" value="4.6" icon={ChartColumn} change={{ value: "0.2", trend: "up" }} />
                <StatCard label="Attendance" value="97%" icon={CircleCheck} tone="success" hint="2 absences this term" />
                <StatCard label="Homework due" value={3} icon={ListCheck} tone="warning" hint="1 overdue" />
                <StatCard label="Next exam" value="Wed" icon={FileText} tone="danger" hint="Algebra mid-term" />
            </div>
            <div className="grid grid-cols-1 gap-4 xl:grid-cols-3">
                <ChartCard title="Timetable" description="Today" action={<SampleDataChip />}>
                    <ScheduleList entries={studentSchedule} />
                </ChartCard>
                <ChartCard title="Scores by subject" description="Current term average" action={<SampleDataChip />} className="xl:col-span-2">
                    <BarsChart data={subjectScores} xKey="subject" yKey="score" label="Score" unit="%" />
                </ChartCard>
            </div>
            <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
                <ChartCard title="Homework" action={<SampleDataChip />}>
                    <TaskList tasks={studentHomework} />
                </ChartCard>
                <ChartCard title="Announcements" action={<SampleDataChip />}>
                    <TaskList tasks={announcements} />
                </ChartCard>
            </div>
        </div>
    );
}
