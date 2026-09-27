import type { ApiUser } from "@/types/api";

export interface LoginPayload {
    email: string;
    password: string;
    remember_me?: boolean;
}

export interface LoginResult {
    access_token: string;
    expires_in: number;
    user: ApiUser;
}

export interface QrLoginStart {
    qr_token: string;
    poll_secret: string;
    expires_at: string;
    expires_in: number;
}

export type QrLoginStatus = "pending" | "scanned" | "approved" | "declined" | "expired" | "consumed";

/** 200 while waiting; 201 with a full login payload once the phone approves. */
export type QrPollResult = { status: Exclude<QrLoginStatus, "approved"> } | ({ status?: undefined } & LoginResult);
