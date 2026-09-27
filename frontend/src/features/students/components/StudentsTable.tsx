"use client";

import { useState } from "react";
import { Avatar, Button, Chip } from "@heroui/react";
import { PersonPlus } from "@gravity-ui/icons";
import { DataTable, type DataColumn } from "@/components/data-table/DataTable";
import { useDebouncedValue } from "@/hooks/useDebouncedValue";
import { useStudents } from "../hooks/useStudents";
import type { Student } from "../types/student.types";

const columns: DataColumn<Student>[] = [
    {
        id: "name",
        header: "Student",
        isRowHeader: true,
        cell: (student) => (
            <div className="flex items-center gap-3">
                <Avatar size="sm" color="accent">
                    <Avatar.Fallback>{`${student.user.first_name[0] ?? ""}${student.user.last_name[0] ?? ""}`}</Avatar.Fallback>
                </Avatar>
                <div className="min-w-0">
                    <p className="truncate font-medium">{`${student.user.first_name} ${student.user.last_name}`}</p>
                    <p className="truncate text-xs text-muted">{student.user.email}</p>
                </div>
            </div>
        ),
    },
    { id: "code", header: "Code", cell: (student) => <span className="font-mono text-xs">{student.student_code}</span> },
    { id: "gender", header: "Gender", cell: (student) => <span className="capitalize">{student.gender ?? "—"}</span> },
    { id: "admitted", header: "Admitted", cell: (student) => student.admission_date ?? "—" },
    {
        id: "status",
        header: "Email",
        cell: (student) =>
            student.user.email_verified ? (
                <Chip size="sm" variant="soft" color="success">
                    Verified
                </Chip>
            ) : (
                <Chip size="sm" variant="soft" color="warning">
                    Pending
                </Chip>
            ),
    },
];

export function StudentsTable() {
    const [search, setSearch] = useState("");
    const [page, setPage] = useState(1);
    const q = useDebouncedValue(search);
    const { data, isFetching, error } = useStudents({ page, limit: 10, q });

    return (
        <DataTable
            ariaLabel="Students"
            columns={columns}
            items={data?.data ?? []}
            meta={data?.meta}
            isLoading={isFetching}
            error={error}
            search={search}
            onSearchChange={(value) => {
                setSearch(value);
                setPage(1);
            }}
            searchPlaceholder="Search by name, email or code"
            onPageChange={setPage}
            toolbar={
                <Button size="sm">
                    <PersonPlus className="size-4" aria-hidden />
                    Add student
                </Button>
            }
        />
    );
}
