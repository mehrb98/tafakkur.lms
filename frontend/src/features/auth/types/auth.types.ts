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
