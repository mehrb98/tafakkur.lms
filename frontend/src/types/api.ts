export type Role = "admin" | "teacher" | "student" | "parent";

export const ROLES: readonly Role[] = ["admin", "teacher", "student", "parent"];

export interface ApiUser {
    id: string;
    email: string;
    first_name: string;
    last_name: string;
    role: Role;
    school_id: string;
    phone?: string | null;
    avatar_url?: string | null;
    email_verified?: boolean;
}

export interface PaginationMeta {
    page: number;
    limit: number;
    total: number;
    total_pages: number;
}

export interface ApiResponse<T> {
    data: T;
}

export interface PaginatedResponse<T> {
    data: T[];
    meta: PaginationMeta;
}

export interface ApiErrorBody {
    error: {
        code: string;
        message: string;
        details: { field: string; message: string }[];
    };
}

export interface ListParams {
    page?: number;
    limit?: number;
    q?: string;
}

export function isRole(value: unknown): value is Role {
    return typeof value === "string" && (ROLES as readonly string[]).includes(value);
}
