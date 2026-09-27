import type { Metadata } from "next";
import { PageHeader } from "@/components/page-header/PageHeader";
import { StudentsTable } from "@/features/students/components/StudentsTable";

export const metadata: Metadata = { title: "Students" };

export default function StudentsPage() {
    return (
        <div>
            <PageHeader title="Students" description="Everyone enrolled at your school." />
            <StudentsTable />
        </div>
    );
}
