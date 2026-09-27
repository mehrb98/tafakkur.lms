import type { ApiUser, Role } from "@/types/api";

/**
 * Client-side session state.
 *
 * The access token lives in memory only (SAD §6.6). The refresh token is an
 * httpOnly cookie set by Rails, so a page reload recovers the access token by
 * calling /auth/refresh. The `lms_role` cookie is readable by proxy.ts for
 * role-based routing; it is a UX hint, never a security boundary.
 */

export const ROLE_COOKIE = "lms_role";
export const DEMO_COOKIE = "lms_demo";
const USER_STORAGE_KEY = "lms_user";

let accessToken: string | null = null;

export function getAccessToken(): string | null {
    return accessToken;
}

export function setAccessToken(token: string | null): void {
    accessToken = token;
}

function writeCookie(name: string, value: string, maxAgeSeconds: number): void {
    document.cookie = `${name}=${encodeURIComponent(value)}; Path=/; Max-Age=${maxAgeSeconds}; SameSite=Lax`;
}

function readCookie(name: string): string | null {
    const match = document.cookie.split("; ").find((part) => part.startsWith(`${name}=`));
    return match ? decodeURIComponent(match.split("=")[1] ?? "") : null;
}

export function isDemoSession(): boolean {
    return typeof document !== "undefined" && readCookie(DEMO_COOKIE) === "1";
}

export function persistSession(user: ApiUser, options: { demo: boolean }): void {
    const thirtyDays = 60 * 60 * 24 * 30;
    writeCookie(ROLE_COOKIE, user.role, thirtyDays);
    writeCookie(DEMO_COOKIE, options.demo ? "1" : "0", thirtyDays);
    try {
        localStorage.setItem(USER_STORAGE_KEY, JSON.stringify(user));
    } catch {
        // Storage can be unavailable (private mode); the session still works in memory.
    }
}

export function loadStoredUser(): ApiUser | null {
    try {
        const raw = localStorage.getItem(USER_STORAGE_KEY);
        return raw ? (JSON.parse(raw) as ApiUser) : null;
    } catch {
        return null;
    }
}

export function clearSession(): void {
    accessToken = null;
    writeCookie(ROLE_COOKIE, "", 0);
    writeCookie(DEMO_COOKIE, "", 0);
    try {
        localStorage.removeItem(USER_STORAGE_KEY);
    } catch {
        // ignore
    }
}

export function dashboardPath(role: Role): string {
    return `/${role}`;
}
