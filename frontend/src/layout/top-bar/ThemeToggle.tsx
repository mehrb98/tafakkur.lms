"use client";

import { useEffect, useState } from "react";
import { Button } from "@heroui/react";
import { Moon, Sun } from "@gravity-ui/icons";
import { useTheme } from "next-themes";

export function ThemeToggle() {
    const [mounted, setMounted] = useState(false);
    const { resolvedTheme, setTheme } = useTheme();

    useEffect(() => {
        setMounted(true);
    }, []);

    const isDark = mounted && resolvedTheme === "dark";

    return (
        <Button
            isIconOnly
            variant="ghost"
            aria-label={
                mounted
                    ? isDark
                        ? "Switch to light theme"
                        : "Switch to dark theme"
                    : "Toggle theme"
            }
            onPress={() => setTheme(isDark ? "light" : "dark")}
        >
            <Sun className="hidden size-4.5 dark:block" aria-hidden />
            <Moon className="size-4.5 dark:hidden" aria-hidden />
        </Button>
    );
}
