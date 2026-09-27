"use client";

import { Button } from "@heroui/react";
import { Moon, Sun } from "@gravity-ui/icons";
import { useTheme } from "next-themes";

export function ThemeToggle() {
    const { resolvedTheme, setTheme } = useTheme();
    const isDark = resolvedTheme === "dark";

    return (
        <Button
            isIconOnly
            variant="ghost"
            aria-label={isDark ? "Switch to light theme" : "Switch to dark theme"}
            onPress={() => setTheme(isDark ? "light" : "dark")}
        >
            <Sun className="hidden size-[18px] dark:block" aria-hidden />
            <Moon className="size-[18px] dark:hidden" aria-hidden />
        </Button>
    );
}
