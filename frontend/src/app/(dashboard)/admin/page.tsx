import type { Metadata } from "next";
import { ChartCard } from "@/components/charts/ChartCard";
import { PageHeader } from "@/components/page-header/PageHeader";
import { AdminStats } from "@/features/dashboard/components/AdminStats";
import { AttendanceChart } from "@/features/dashboard/components/AttendanceChart";
import { BarsChart } from "@/features/dashboard/components/BarsChart";
import { RecentStudents } from "@/features/dashboard/components/RecentStudents";
import { SampleDataChip } from "@/features/dashboard/components/SampleDataChip";
import { ScheduleList } from "@/features/dashboard/components/ScheduleList";
import { gradeDistribution, upcomingEvents, weeklyAttendance } from "@/features/dashboard/data/mock";

export const metadata: Metadata = { title: "Admin dashboard" };

export default function AdminDashboardPage() {
    return (
        <div className="flex flex-col gap-6">
            <PageHeader title="School overview" description="Headcounts, attendance and academic performance at a glance." />
            <AdminStats />
            <div className="grid grid-cols-1 gap-4 xl:grid-cols-3">
                <ChartCard title="Attendance this week" description="Share of students present" action={<SampleDataChip />} className="xl:col-span-2">
                    <AttendanceChart data={weeklyAttendance} />
                </ChartCard>
                <ChartCard title="Grade distribution" description="Current term, all subjects" action={<SampleDataChip />}>
                    <BarsChart data={gradeDistribution} xKey="label" yKey="count" label="Grades" color="var(--success)" />
                </ChartCard>
            </div>
            <div className="grid grid-cols-1 gap-4 xl:grid-cols-3">
                <ChartCard title="Recently added students" description="Newest enrollments">
                    <RecentStudents />
                </ChartCard>
                <ChartCard title="Upcoming events" description="Next 7 days" action={<SampleDataChip />} className="xl:col-span-2">
                    <ScheduleList entries={upcomingEvents} />
                </ChartCard>
            </div>
        </div>
    );
}
