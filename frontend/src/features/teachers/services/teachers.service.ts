import { apiGet } from "@/lib/api/client";
import { isDemoSession } from "@/lib/auth/session";
import { delay, demoPerson, paginateDemo } from "@/lib/api/demo";
import type { ListParams, PaginatedResponse } from "@/types/api";
import type { Teacher } from "../types/teacher.types";

const SPECIALIZATIONS = ["Mathematics", "Physics", "English", "History", "Biology", "Uzbek language", "Chemistry", "Computer science"];

const DEMO_TEACHERS: Teacher[] = Array.from({ length: 23 }, (_, index) => ({
    id: `demo-teacher-${index}`,
    employee_code: `EMP-${String(index + 101)}`,
    specialization: SPECIALIZATIONS[index % SPECIALIZATIONS.length],
    hire_date: `20${12 + (index % 12)}-08-15`,
    department_id: null,
    user: demoPerson(index + 40, "teacher"),
}));

export async function listTeachers(params: ListParams): Promise<PaginatedResponse<Teacher>> {
    if (isDemoSession()) {
        await delay();
        return paginateDemo(DEMO_TEACHERS, params, (teacher, q) =>
            `${teacher.user.first_name} ${teacher.user.last_name} ${teacher.user.email} ${teacher.specialization ?? ""}`
                .toLowerCase()
                .includes(q),
        );
    }
    return apiGet<PaginatedResponse<Teacher>>("/teachers", { ...params });
}
