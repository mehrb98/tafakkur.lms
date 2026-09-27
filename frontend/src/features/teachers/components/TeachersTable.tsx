"use client";

import { useState } from "react";
import { Avatar, Button, Chip } from "@heroui/react";
import { PersonPlus } from "@gravity-ui/icons";
import { DataTable, type DataColumn } from "@/components/data-table/DataTable";
import { useDebouncedValue } from "@/hooks/useDebouncedValue";
import { useTeachers } from "../hooks/useTeachers";
import type { Teacher } from "../types/teacher.types";

const columns: DataColumn<Teacher>[] = [
    {
        id: "name",
        header: "Teacher",
        isRowHeader: true,
        cell: (teacher) => (
            <div className="flex items-center gap-3">
                <Avatar size="sm" color="success">
                    <Avatar.Fallback>{`${teacher.user.first_name[0] ?? ""}${teacher.user.last_name[0] ?? ""}`}</Avatar.Fallback>
                </Avatar>
                <div className="min-w-0">
                    <p className="truncate font-medium">{`${teacher.user.first_name} ${teacher.user.last_name}`}</p>
                    <p className="truncate text-xs text-muted">{teacher.user.email}</p>
                </div>
            </div>
        ),
    },
    { id: "code", header: "Employee code", cell: (teacher) => <span className="font-mono text-xs">{teacher.employee_code}</span> },
    {
        id: "specialization",
        header: "Specialization",
        cell: (teacher) =>
            teacher.specialization ? (
                <Chip size="sm" variant="soft" color="accent">
                    {teacher.specialization}
                </Chip>
            ) : (
                "—"
            ),
    },
    { id: "hired", header: "Hired", cell: (teacher) => teacher.hire_date ?? "—" },
    { id: "phone", header: "Phone", cell: (teacher) => teacher.user.phone ?? "—" },
];

export function TeachersTable() {
    const [search, setSearch] = useState("");
    const [page, setPage] = useState(1);
    const q = useDebouncedValue(search);
    const { data, isFetching, error } = useTeachers({ page, limit: 10, q });

    return (
        <DataTable
            ariaLabel="Teachers"
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
            searchPlaceholder="Search by name or subject"
            onPageChange={setPage}
            toolbar={
                <Button size="sm">
                    <PersonPlus className="size-4" aria-hidden />
                    Add teacher
                </Button>
            }
        />
    );
}
