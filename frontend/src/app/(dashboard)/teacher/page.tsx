import type { Metadata } from "next";
import { CircleCheck, Clock, Layers, ListCheck } from "@gravity-ui/icons";
import { ChartCard } from "@/components/charts/ChartCard";
import { PageHeader } from "@/components/page-header/PageHeader";
import { StatCard } from "@/components/stat-card/StatCard";
import { AttendanceChart } from "@/features/dashboard/components/AttendanceChart";
import { SampleDataChip } from "@/features/dashboard/components/SampleDataChip";
import { ScheduleList } from "@/features/dashboard/components/ScheduleList";
import { TaskList } from "@/features/dashboard/components/TaskList";
import { teacherSchedule, teacherTasks, weeklyAttendance } from "@/features/dashboard/data/mock";

export const metadata: Metadata = { title: "Teacher dashboard" };

export default function TeacherDashboardPage() {
    return (
        <div className="flex flex-col gap-6">
            <PageHeader title="Today" description="Your lessons, classes and what needs attention." />
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
                <StatCard label="Lessons today" value={4} icon={Clock} hint="Next at 11:10" />
                <StatCard label="My classes" value={6} icon={Layers} tone="success" hint="168 students" />
                <StatCard label="To grade" value={28} icon={ListCheck} tone="warning" hint="Quiz #4, Grade 9-A" />
                <StatCard label="Attendance" value="94%" icon={CircleCheck} tone="danger" change={{ value: "1.2%", trend: "up" }} />
            </div>
            <div className="grid grid-cols-1 gap-4 xl:grid-cols-3">
                <ChartCard title="Schedule" description="Today's lessons" action={<SampleDataChip />}>
                    <ScheduleList entries={teacherSchedule} />
                </ChartCard>
                <ChartCard title="Class attendance" description="This week, all your classes" action={<SampleDataChip />} className="xl:col-span-2">
                    <AttendanceChart data={weeklyAttendance} />
                </ChartCard>
            </div>
            <ChartCard title="To do" description="Grading, attendance and homework" action={<SampleDataChip />}>
                <TaskList tasks={teacherTasks} />
            </ChartCard>
        </div>
    );
}
