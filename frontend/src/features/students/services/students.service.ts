import { apiGet } from "@/lib/api/client";
import { isDemoSession } from "@/lib/auth/session";
import { delay, demoPerson, paginateDemo } from "@/lib/api/demo";
import type { ListParams, PaginatedResponse } from "@/types/api";
import type { Student } from "../types/student.types";

const DEMO_STUDENTS: Student[] = Array.from({ length: 64 }, (_, index) => ({
    id: `demo-student-${index}`,
    student_code: `STU-2026-${String(index + 1).padStart(4, "0")}`,
    date_of_birth: `20${10 + (index % 6)}-0${(index % 9) + 1}-1${index % 9}`,
    gender: index % 2 === 0 ? "female" : "male",
    address: "Tashkent",
    admission_date: `202${index % 5}-09-01`,
    user: demoPerson(index, "student"),
}));

export async function listStudents(params: ListParams): Promise<PaginatedResponse<Student>> {
    if (isDemoSession()) {
        await delay();
        return paginateDemo(DEMO_STUDENTS, params, (student, q) =>
            `${student.user.first_name} ${student.user.last_name} ${student.user.email} ${student.student_code}`
                .toLowerCase()
                .includes(q),
        );
    }
    return apiGet<PaginatedResponse<Student>>("/students", { ...params });
}
