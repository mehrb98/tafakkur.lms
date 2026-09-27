import { apiPostNoContent, publicApi } from "@/lib/api/client";
import type { ApiResponse, ApiUser, Role } from "@/types/api";
import type { LoginPayload, LoginResult, QrLoginStart, QrPollResult } from "../types/auth.types";

export async function login(payload: LoginPayload): Promise<LoginResult> {
    const body = await publicApi.url("/auth/login").post(payload).json<ApiResponse<LoginResult>>();
    return body.data;
}

export async function startQrLogin(): Promise<QrLoginStart> {
    const body = await publicApi.url("/auth/qr").post().json<ApiResponse<QrLoginStart>>();
    return body.data;
}

export async function pollQrLogin(pollSecret: string): Promise<QrPollResult> {
    const body = await publicApi.url("/auth/qr/poll").post({ poll_secret: pollSecret }).json<ApiResponse<QrPollResult>>();
    return body.data;
}

/** The QR code content the mobile app recognises. */
export function qrLoginUri(qrToken: string): string {
    return `tafakkur://qr-login?token=${encodeURIComponent(qrToken)}`;
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
