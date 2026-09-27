import { apiPostNoContent, publicApi } from "@/lib/api/client";
import type { ApiResponse, ApiUser, Role } from "@/types/api";
import type { LoginPayload, LoginResult } from "../types/auth.types";

export async function login(payload: LoginPayload): Promise<LoginResult> {
    const body = await publicApi.url("/auth/login").post(payload).json<ApiResponse<LoginResult>>();
    return body.data;
}

export async function logout(): Promise<void> {
    await apiPostNoContent("/auth/logout");
}

const DEMO_NAMES: Record<Role, { first_name: string; last_name: string }> = {
    admin: { first_name: "Dilnoza", last_name: "Karimova" },
    teacher: { first_name: "Aziz", last_name: "Rahimov" },
    student: { first_name: "Malika", last_name: "Yusupova" },
    parent: { first_name: "Sardor", last_name: "Yusupov" },
};

/** A local-only user for exploring the dashboard without a running backend. */
export function demoUser(role: Role): ApiUser {
    return {
        id: `demo-${role}`,
        email: `${role}@demo.tafakkur.uz`,
        role,
        school_id: "demo-school",
        email_verified: true,
        avatar_url: null,
        ...DEMO_NAMES[role],
    };
}
