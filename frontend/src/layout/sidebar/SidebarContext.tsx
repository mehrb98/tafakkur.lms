"use client";

import { createContext, use, useCallback, useEffect, useMemo, useState, type ReactNode } from "react";

interface SidebarContextValue {
    isCollapsed: boolean;
    toggleCollapsed: () => void;
    isMobileOpen: boolean;
    setMobileOpen: (open: boolean) => void;
}

const SidebarContext = createContext<SidebarContextValue | null>(null);
const STORAGE_KEY = "lms_sidebar_collapsed";

export function SidebarProvider({ children }: { children: ReactNode }) {
    const [isCollapsed, setCollapsed] = useState(false);
    const [isMobileOpen, setMobileOpen] = useState(false);

    useEffect(() => {
        try {
            // eslint-disable-next-line react-hooks/set-state-in-effect -- one-time sync from browser storage
            setCollapsed(localStorage.getItem(STORAGE_KEY) === "1");
        } catch {
            // Storage unavailable: keep the expanded default.
        }
    }, []);

    const toggleCollapsed = useCallback(() => {
        setCollapsed((previous) => {
            const next = !previous;
            try {
                localStorage.setItem(STORAGE_KEY, next ? "1" : "0");
            } catch {
                // ignore
            }
            return next;
        });
    }, []);

    const value = useMemo(
        () => ({ isCollapsed, toggleCollapsed, isMobileOpen, setMobileOpen }),
        [isCollapsed, toggleCollapsed, isMobileOpen],
    );

    return <SidebarContext value={value}>{children}</SidebarContext>;
}

export function useSidebar(): SidebarContextValue {
    const context = use(SidebarContext);
    if (!context) {
        throw new Error("useSidebar must be used inside <SidebarProvider>");
    }
    return context;
}
