"use client";

import { createContext, use, useCallback, useEffect, useMemo, useState, type ReactNode } from "react";
import { useRouter } from "next/navigation";
import { useQueryClient } from "@tanstack/react-query";
import { logout as logoutRequest } from "@/features/auth/services/auth.service";
import {
    clearSession,
    dashboardPath,
    isDemoSession,
    loadStoredUser,
    persistSession,
    setAccessToken,
} from "@/lib/auth/session";
import type { ApiUser } from "@/types/api";

interface AuthContextValue {
    user: ApiUser | null;
    isDemo: boolean;
    signIn: (user: ApiUser, options: { accessToken?: string; demo: boolean }) => void;
    signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
    const router = useRouter();
    const queryClient = useQueryClient();
    const [user, setUser] = useState<ApiUser | null>(null);
    const [isDemo, setIsDemo] = useState(false);

    // Restore the profile after hydration so server and client render the same first frame.
    useEffect(() => {
        // eslint-disable-next-line react-hooks/set-state-in-effect -- one-time sync from browser storage
        setUser(loadStoredUser());
        setIsDemo(isDemoSession());
    }, []);

    const signIn = useCallback<AuthContextValue["signIn"]>(
        (nextUser, { accessToken, demo }) => {
            setAccessToken(accessToken ?? null);
            persistSession(nextUser, { demo });
            setUser(nextUser);
            setIsDemo(demo);
            queryClient.clear();
            router.replace(dashboardPath(nextUser.role));
        },
        [queryClient, router],
    );

    const signOut = useCallback(async () => {
        if (!isDemo) {
            try {
                await logoutRequest();
            } catch {
                // The session is cleared locally even if the server call fails.
            }
        }
        clearSession();
        setUser(null);
        setIsDemo(false);
        queryClient.clear();
        router.replace("/auth/login");
    }, [isDemo, queryClient, router]);

    const value = useMemo(() => ({ user, isDemo, signIn, signOut }), [user, isDemo, signIn, signOut]);

    return <AuthContext value={value}>{children}</AuthContext>;
}

export function useAuth(): AuthContextValue {
    const context = use(AuthContext);
    if (!context) {
        throw new Error("useAuth must be used inside <AuthProvider>");
    }
    return context;
}
