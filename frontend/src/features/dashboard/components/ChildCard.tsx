import Link from "next/link";
import { Avatar, Card, Chip, ProgressBar, Label } from "@heroui/react";
import type { ChildSummary } from "../types/dashboard.types";

export function ChildCard({ child }: { child: ChildSummary }) {
    const initials = child.name
        .split(" ")
        .map((part) => part[0])
        .join("");

    return (
        <Card className="gap-5 p-5">
            <div className="flex items-center gap-3">
                <Avatar color="accent">
                    <Avatar.Fallback>{initials}</Avatar.Fallback>
                </Avatar>
                <div className="min-w-0 flex-1">
                    <p className="truncate font-semibold">{child.name}</p>
                    <p className="truncate text-sm text-muted">{child.className}</p>
                </div>
                {child.homeworkDue > 0 && (
                    <Chip size="sm" variant="soft" color="warning">
                        {child.homeworkDue} due
                    </Chip>
                )}
            </div>
            <div className="grid grid-cols-2 gap-4">
                <div>
                    <p className="text-xs text-muted">Average grade</p>
                    <p className="text-2xl font-semibold tabular-nums">{child.average.toFixed(1)}</p>
                </div>
                <ProgressBar value={child.attendance} color="success" size="sm" className="self-end">
                    <div className="flex justify-between text-xs">
                        <Label>Attendance</Label>
                        <ProgressBar.Output />
                    </div>
                    <ProgressBar.Track>
                        <ProgressBar.Fill />
                    </ProgressBar.Track>
                </ProgressBar>
            </div>
            <Link href={`/parent/children/${child.id}`} className="text-sm font-medium text-accent hover:underline">
                View details
            </Link>
        </Card>
    );
}
