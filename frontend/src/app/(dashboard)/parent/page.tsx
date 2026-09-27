import type { Metadata } from "next";
import { ChartCard } from "@/components/charts/ChartCard";
import { PageHeader } from "@/components/page-header/PageHeader";
import { AttendanceChart } from "@/features/dashboard/components/AttendanceChart";
import { ChildCard } from "@/features/dashboard/components/ChildCard";
import { SampleDataChip } from "@/features/dashboard/components/SampleDataChip";
import { TaskList } from "@/features/dashboard/components/TaskList";
import { announcements, parentChildren, weeklyAttendance } from "@/features/dashboard/data/mock";

export const metadata: Metadata = { title: "Parent dashboard" };

export default function ParentDashboardPage() {
    return (
        <div className="flex flex-col gap-6">
            <PageHeader title="My children" description="Grades, attendance and homework for each child." />
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                {parentChildren.map((child) => (
                    <ChildCard key={child.id} child={child} />
                ))}
            </div>
            <div className="grid grid-cols-1 gap-4 xl:grid-cols-3">
                <ChartCard title="Attendance" description="This week" action={<SampleDataChip />} className="xl:col-span-2">
                    <AttendanceChart data={weeklyAttendance} />
                </ChartCard>
                <ChartCard title="School announcements" action={<SampleDataChip />}>
                    <TaskList tasks={announcements} />
                </ChartCard>
            </div>
        </div>
    );
}
