"use client";

import { GraduationCap, Layers, PersonWorker, Persons } from "@gravity-ui/icons";
import { StatCard } from "@/components/stat-card/StatCard";
import { useSchoolCounts } from "../hooks/useSchoolCounts";

const number = new Intl.NumberFormat("en-US");

export function AdminStats() {
    const { data, isLoading, error } = useSchoolCounts();
    const hint = error ? "Couldn't reach the API" : undefined;

    return (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <StatCard label="Students" value={data && number.format(data.students)} icon={GraduationCap} isLoading={isLoading} hint={hint} />
            <StatCard label="Teachers" value={data && number.format(data.teachers)} icon={PersonWorker} tone="success" isLoading={isLoading} hint={hint} />
            <StatCard label="Parents" value={data && number.format(data.parents)} icon={Persons} tone="warning" isLoading={isLoading} hint={hint} />
            <StatCard label="Classes" value={data && number.format(data.classes)} icon={Layers} tone="danger" isLoading={isLoading} hint={hint} />
        </div>
    );
}
