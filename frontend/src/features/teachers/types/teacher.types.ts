import type { ApiUser } from "@/types/api";

export interface Teacher {
    id: string;
    employee_code: string;
    specialization: string | null;
    hire_date: string | null;
    department_id: string | null;
    user: ApiUser;
}
