import wretch from "wretch";
import QueryStringAddon from "wretch/addons/queryString";
import { clearSession, getAccessToken, setAccessToken } from "@/lib/auth/session";
import type { ApiErrorBody, ApiResponse } from "@/types/api";

export const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:3001/api/v1";

export class ApiError extends Error {
    constructor(
        public readonly status: number,
        public readonly code: string,
        message: string,
        public readonly details: ApiErrorBody["error"]["details"] = [],
    ) {
        super(message);
        this.name = "ApiError";
    }
}

/** Base client: JSON, cookies for the refresh token, Rails error envelope parsed into ApiError. */
const base = wretch(API_URL)
    .addon(QueryStringAddon)
    .options({ credentials: "include" })
    .headers({ Accept: "application/json" })
    .customError<ApiError>(async (error, response) => {
        let body: Partial<ApiErrorBody> = {};
        try {
            body = (await response.clone().json()) as ApiErrorBody;
        } catch {
            // Non-JSON error body; fall back to the HTTP status text.
        }
        return new ApiError(
            error.status,
            body.error?.code ?? "http_error",
            body.error?.message ?? response.statusText ?? error.message,
            body.error?.details ?? [],
        );
    });

/** Unauthenticated calls (login, refresh, password reset). */
export const publicApi = base;

let refreshing: Promise<string | null> | null = null;

/** Rotates the refresh cookie and stores the new access token. Concurrent callers share one request. */
export function refreshAccessToken(): Promise<string | null> {
    refreshing ??= base
        .url("/auth/refresh")
        .post()
        .json<ApiResponse<{ access_token: string }>>()
        .then((body) => {
            setAccessToken(body.data.access_token);
            return body.data.access_token;
        })
        .catch(() => null)
        .finally(() => {
            refreshing = null;
        });
    return refreshing;
}

type Query = Record<string, string | number | undefined>;

function withAuth() {
    const token = getAccessToken();
    return token ? base.auth(`Bearer ${token}`) : base;
}

function compactQuery(query: Query): Record<string, string | number> {
    return Object.fromEntries(
        Object.entries(query).filter((entry): entry is [string, string | number] => entry[1] !== undefined && entry[1] !== ""),
    );
}

/**
 * Authenticated GET. On 401 it refreshes the access token once and retries;
 * if the refresh fails the session is cleared and the user is sent to login.
 */
export async function apiGet<T>(path: string, query: Query = {}): Promise<T> {
    const run = () => withAuth().url(path).query(compactQuery(query)).get().json<T>();
    try {
        return await run();
    } catch (error) {
        if (!(error instanceof ApiError) || error.status !== 401) {
            throw error;
        }
        const token = await refreshAccessToken();
        if (!token) {
            clearSession();
            if (typeof window !== "undefined") {
                // Outside React here, so a hard navigation is the only option.
                // eslint-disable-next-line @next/next/no-location-assign-relative-destination
                window.location.assign("/auth/login");
            }
            throw error;
        }
        return run();
    }
}

/** Authenticated POST for endpoints that answer 204 No Content. */
export async function apiPostNoContent(path: string, body?: unknown): Promise<void> {
    await withAuth().url(path).post(body).res();
}
