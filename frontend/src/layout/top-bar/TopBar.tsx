"use client";

import { usePathname, useRouter } from "next/navigation";
import { Avatar, Badge, Button, Chip, Dropdown, Label, SearchField } from "@heroui/react";
import { ArrowRightFromSquare, Bars, Bell, Gear, Person, Shield } from "@gravity-ui/icons";
import { findActiveItem, ROLE_LABELS } from "@/lib/navigation/nav";
import { useAuth } from "@/providers/AuthProvider";
import { useSidebar } from "@/layout/sidebar/SidebarContext";
import type { Role } from "@/types/api";
import { ThemeToggle } from "./ThemeToggle";

interface TopBarProps {
    role: Role;
}

export function TopBar({ role }: TopBarProps) {
    const pathname = usePathname();
    const router = useRouter();
    const { user, isDemo, signOut } = useAuth();
    const { setMobileOpen } = useSidebar();
    const title = findActiveItem(role, pathname)?.label ?? "Dashboard";
    const initials = `${user?.first_name?.[0] ?? ""}${user?.last_name?.[0] ?? ""}`.toUpperCase() || "?";

    return (
        <header className="sticky top-0 z-30 flex h-16 items-center gap-3 border-b border-separator bg-background/80 px-4 backdrop-blur-md sm:px-6">
            <Button
                isIconOnly
                variant="ghost"
                aria-label="Open navigation"
                className="lg:hidden"
                onPress={() => setMobileOpen(true)}
            >
                <Bars className="size-5" aria-hidden />
            </Button>

            <div className="flex min-w-0 items-center gap-2">
                <h1 className="truncate text-base font-semibold sm:text-lg">{title}</h1>
                {isDemo && (
                    <Chip size="sm" variant="soft" color="warning">
                        Demo data
                    </Chip>
                )}
            </div>

            <div className="ml-auto flex items-center gap-1 sm:gap-2">
                <SearchField aria-label="Search" className="hidden w-64 md:block">
                    <Label className="sr-only">Search</Label>
                    <SearchField.Group>
                        <SearchField.SearchIcon />
                        <SearchField.Input placeholder="Search students, classes…" />
                        <SearchField.ClearButton />
                    </SearchField.Group>
                </SearchField>

                <ThemeToggle />

                <Badge.Anchor>
                    <Button isIconOnly variant="ghost" aria-label="Notifications, 3 unread">
                        <Bell className="size-[18px]" aria-hidden />
                    </Button>
                    <Badge color="danger" size="sm" placement="top-right">
                        3
                    </Badge>
                </Badge.Anchor>

                <Dropdown>
                    <Dropdown.Trigger aria-label="Account menu" className="rounded-full outline-none focus-visible:ring-2 focus-visible:ring-focus">
                        <Avatar size="sm" color="accent">
                            {user?.avatar_url && <Avatar.Image src={user.avatar_url} alt="" />}
                            <Avatar.Fallback>{initials}</Avatar.Fallback>
                        </Avatar>
                    </Dropdown.Trigger>
                    <Dropdown.Popover placement="bottom end" className="min-w-56">
                        <div className="px-3 pb-1 pt-3">
                            <p className="truncate text-sm font-medium">
                                {user ? `${user.first_name} ${user.last_name}` : ROLE_LABELS[role]}
                            </p>
                            <p className="truncate text-xs text-muted">{user?.email}</p>
                        </div>
                        <Dropdown.Menu
                            aria-label="Account"
                            onAction={(key) => {
                                if (key === "logout") {
                                    void signOut();
                                } else {
                                    router.push(`/${role}/${String(key)}`);
                                }
                            }}
                        >
                            <Dropdown.Item id="profile" textValue="Profile">
                                <Person className="size-4 text-muted" aria-hidden />
                                <Label>Profile</Label>
                            </Dropdown.Item>
                            <Dropdown.Item id="security" textValue="Security">
                                <Shield className="size-4 text-muted" aria-hidden />
                                <Label>Security</Label>
                            </Dropdown.Item>
                            <Dropdown.Item id="settings" textValue="Settings">
                                <Gear className="size-4 text-muted" aria-hidden />
                                <Label>Settings</Label>
                            </Dropdown.Item>
                            <Dropdown.Item id="logout" textValue="Sign out" variant="danger">
                                <ArrowRightFromSquare className="size-4" aria-hidden />
                                <Label>Sign out</Label>
                            </Dropdown.Item>
                        </Dropdown.Menu>
                    </Dropdown.Popover>
                </Dropdown>
            </div>
        </header>
    );
}
