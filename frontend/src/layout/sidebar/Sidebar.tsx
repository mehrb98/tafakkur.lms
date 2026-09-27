"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Avatar, Button, Chip, Drawer, Separator, Tooltip } from "@heroui/react";
import { ChevronLeft, ChevronRight, GraduationCap } from "@gravity-ui/icons";
import { findActiveItem, NAVIGATION, ROLE_LABELS, type NavItem } from "@/lib/navigation/nav";
import { useAuth } from "@/providers/AuthProvider";
import type { Role } from "@/types/api";
import { useSidebar } from "./SidebarContext";

interface SidebarProps {
    role: Role;
}

function initials(first?: string, last?: string): string {
    return `${first?.[0] ?? ""}${last?.[0] ?? ""}`.toUpperCase() || "?";
}

function Brand({ compact }: { compact: boolean }) {
    return (
        <div className="flex h-16 items-center gap-3 px-4">
            <div className="flex size-9 shrink-0 items-center justify-center rounded-xl bg-accent text-accent-foreground">
                <GraduationCap className="size-5" aria-hidden />
            </div>
            {!compact && (
                <div className="min-w-0">
                    <p className="truncate text-sm font-semibold">Tafakkur LMS</p>
                    <p className="truncate text-xs text-muted">School workspace</p>
                </div>
            )}
        </div>
    );
}

function NavLink({ item, isActive, compact, onNavigate }: { item: NavItem; isActive: boolean; compact: boolean; onNavigate?: () => void }) {
    const Icon = item.icon;
    const link = (
        <Link
            href={item.href}
            onClick={onNavigate}
            aria-current={isActive ? "page" : undefined}
            aria-label={compact ? item.label : undefined}
            className={[
                "group flex h-10 items-center gap-3 rounded-xl px-3 text-sm font-medium outline-none transition-colors",
                "focus-visible:ring-2 focus-visible:ring-focus",
                compact ? "justify-center px-0" : "",
                isActive
                    ? "bg-accent-soft text-accent-soft-foreground"
                    : "text-muted hover:bg-default hover:text-foreground",
            ].join(" ")}
        >
            <Icon className="size-[18px] shrink-0" aria-hidden />
            {!compact && <span className="truncate">{item.label}</span>}
            {!compact && item.badge && (
                <Chip size="sm" variant="soft" color="accent" className="ml-auto">
                    {item.badge}
                </Chip>
            )}
        </Link>
    );

    if (!compact) {
        return link;
    }

    return (
        <Tooltip delay={0}>
            <Tooltip.Trigger>{link}</Tooltip.Trigger>
            <Tooltip.Content placement="right">{item.label}</Tooltip.Content>
        </Tooltip>
    );
}

function SidebarBody({ role, compact, onNavigate }: { role: Role; compact: boolean; onNavigate?: () => void }) {
    const pathname = usePathname();
    const { user } = useAuth();
    const active = findActiveItem(role, pathname);

    return (
        <div className="flex h-full flex-col">
            <Brand compact={compact} />
            <Separator />
            <nav aria-label="Main" className="flex-1 overflow-y-auto px-3 py-4">
                <div className="flex flex-col gap-5">
                    {NAVIGATION[role].map((section, index) => (
                        <div key={section.title ?? index} className="flex flex-col gap-1">
                            {section.title && !compact && (
                                <p className="px-3 pb-1 text-[11px] font-semibold uppercase tracking-wider text-muted">
                                    {section.title}
                                </p>
                            )}
                            {section.title && compact && <Separator className="my-1" />}
                            {section.items.map((item) => (
                                <NavLink
                                    key={item.href}
                                    item={item}
                                    isActive={active?.href === item.href}
                                    compact={compact}
                                    onNavigate={onNavigate}
                                />
                            ))}
                        </div>
                    ))}
                </div>
            </nav>
            <Separator />
            <div className={`flex items-center gap-3 p-4 ${compact ? "justify-center" : ""}`}>
                <Avatar size="sm" color="accent">
                    {user?.avatar_url && <Avatar.Image src={user.avatar_url} alt="" />}
                    <Avatar.Fallback>{initials(user?.first_name, user?.last_name)}</Avatar.Fallback>
                </Avatar>
                {!compact && (
                    <div className="min-w-0">
                        <p className="truncate text-sm font-medium">
                            {user ? `${user.first_name} ${user.last_name}` : " "}
                        </p>
                        <p className="truncate text-xs text-muted">{ROLE_LABELS[role]}</p>
                    </div>
                )}
            </div>
        </div>
    );
}

export function Sidebar({ role }: SidebarProps) {
    const { isCollapsed, toggleCollapsed, isMobileOpen, setMobileOpen } = useSidebar();

    return (
        <div className="contents">
            <aside
                className={[
                    "relative hidden shrink-0 border-r border-separator bg-surface transition-[width] duration-200 lg:block",
                    isCollapsed ? "w-[76px]" : "w-64",
                ].join(" ")}
            >
                <div className="sticky top-0 h-dvh">
                    <SidebarBody role={role} compact={isCollapsed} />
                </div>
                <Button
                    isIconOnly
                    size="sm"
                    variant="tertiary"
                    aria-label={isCollapsed ? "Expand sidebar" : "Collapse sidebar"}
                    onPress={toggleCollapsed}
                    className="absolute -right-3.5 top-5 z-10 size-7 min-w-7 rounded-full border border-separator bg-surface shadow-sm"
                >
                    {isCollapsed ? <ChevronRight className="size-3.5" /> : <ChevronLeft className="size-3.5" />}
                </Button>
            </aside>

            <Drawer isOpen={isMobileOpen} onOpenChange={setMobileOpen}>
                <Drawer.Backdrop>
                    <Drawer.Content placement="left" className="w-72 max-w-[85vw] p-0">
                        <Drawer.Dialog aria-label="Navigation" className="h-full p-0">
                            <SidebarBody role={role} compact={false} onNavigate={() => setMobileOpen(false)} />
                        </Drawer.Dialog>
                    </Drawer.Content>
                </Drawer.Backdrop>
            </Drawer>
        </div>
    );
}
