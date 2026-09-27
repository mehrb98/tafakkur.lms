import type { ApiUser } from "@/types/api";

export interface Student {
    id: string;
    student_code: string;
    date_of_birth: string | null;
    gender: string | null;
    address: string | null;
    admission_date: string | null;
    user: ApiUser;
}
