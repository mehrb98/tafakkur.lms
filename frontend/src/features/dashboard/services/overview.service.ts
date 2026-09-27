import { apiGet } from "@/lib/api/client";
import { isDemoSession } from "@/lib/auth/session";
import { delay } from "@/lib/api/demo";
import type { PaginatedResponse } from "@/types/api";

export interface SchoolCounts {
    students: number;
    teachers: number;
    parents: number;
    classes: number;
}

async function countOf(path: string): Promise<number> {
    const body = await apiGet<PaginatedResponse<unknown>>(path, { limit: 1 });
    return body.meta.total;
}

/** Headcounts from the index endpoints' pagination meta (the API has no aggregate endpoint yet). */
export async function fetchSchoolCounts(): Promise<SchoolCounts> {
    if (isDemoSession()) {
        await delay();
        return { students: 1248, teachers: 86, parents: 1032, classes: 42 };
    }
    const [students, teachers, parents, classes] = await Promise.all([
        countOf("/students"),
        countOf("/teachers"),
        countOf("/parents"),
        countOf("/classes"),
    ]);
    return { students, teachers, parents, classes };
}
