import type { Metadata } from "next";
import { PageHeader } from "@/components/page-header/PageHeader";
import { TeachersTable } from "@/features/teachers/components/TeachersTable";

export const metadata: Metadata = { title: "Teachers" };

export default function TeachersPage() {
    return (
        <div>
            <PageHeader title="Teachers" description="Teaching staff and their specializations." />
            <TeachersTable />
        </div>
    );
}
