"use client";

import Link from "next/link";
import { Avatar, Skeleton } from "@heroui/react";
import { useStudents } from "@/features/students/hooks/useStudents";

export function RecentStudents() {
    const { data, isLoading, error } = useStudents({ page: 1, limit: 5 });

    if (isLoading) {
        return (
            <div className="flex flex-col gap-3">
                {Array.from({ length: 5 }, (_, index) => (
                    <Skeleton key={index} className="h-10 rounded-xl" />
                ))}
            </div>
        );
    }

    if (error) {
        return <p className="text-sm text-muted">Couldn&apos;t load students: {error.message}</p>;
    }

    const students = data?.data ?? [];
    if (students.length === 0) {
        return <p className="text-sm text-muted">No students yet.</p>;
    }

    return (
        <div className="flex flex-col gap-3">
            <ul className="flex flex-col gap-3">
                {students.map((student) => (
                    <li key={student.id} className="flex items-center gap-3">
                        <Avatar size="sm" color="accent">
                            <Avatar.Fallback>{`${student.user.first_name[0] ?? ""}${student.user.last_name[0] ?? ""}`}</Avatar.Fallback>
                        </Avatar>
                        <div className="min-w-0 flex-1">
                            <p className="truncate text-sm font-medium">{`${student.user.first_name} ${student.user.last_name}`}</p>
                            <p className="truncate text-xs text-muted">{student.student_code}</p>
                        </div>
                    </li>
                ))}
            </ul>
            <Link href="/admin/students" className="text-sm font-medium text-accent hover:underline">
                View all students
            </Link>
        </div>
    );
}
