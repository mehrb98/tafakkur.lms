import type { ComponentType, SVGProps } from "react";
import { Card, Chip, Skeleton } from "@heroui/react";

type Tone = "accent" | "success" | "warning" | "danger";

interface StatCardProps {
    label: string;
    value: string | number | undefined;
    icon: ComponentType<SVGProps<SVGSVGElement>>;
    tone?: Tone;
    change?: { value: string; trend: "up" | "down" };
    hint?: string;
    isLoading?: boolean;
}

const TONE_CLASSES: Record<Tone, string> = {
    accent: "bg-accent-soft text-accent-soft-foreground",
    success: "bg-success-soft text-success-soft-foreground",
    warning: "bg-warning-soft text-warning-soft-foreground",
    danger: "bg-danger-soft text-danger-soft-foreground",
};

export function StatCard({ label, value, icon: Icon, tone = "accent", change, hint, isLoading }: StatCardProps) {
    return (
        <Card className="gap-4 p-5">
            <div className="flex items-start justify-between gap-3">
                <p className="text-sm font-medium text-muted">{label}</p>
                <div className={`flex size-10 items-center justify-center rounded-xl ${TONE_CLASSES[tone]}`}>
                    <Icon className="size-5" aria-hidden />
                </div>
            </div>
            <div className="flex items-end justify-between gap-2">
                {isLoading ? (
                    <Skeleton className="h-8 w-20 rounded-lg" />
                ) : (
                    <p className="text-3xl font-semibold tracking-tight tabular-nums">{value ?? "—"}</p>
                )}
                {change && (
                    <Chip size="sm" variant="soft" color={change.trend === "up" ? "success" : "danger"}>
                        {change.trend === "up" ? "▲" : "▼"} {change.value}
                    </Chip>
                )}
            </div>
            {hint && <p className="-mt-2 text-xs text-muted">{hint}</p>}
        </Card>
    );
}
