import { Chip } from "@heroui/react";
import type { ScheduleEntry } from "../types/dashboard.types";

const STATUS_LABEL = { done: "Done", now: "Now", next: "Next" } as const;
const STATUS_COLOR = { done: "default", now: "success", next: "accent" } as const;

export function ScheduleList({ entries }: { entries: ScheduleEntry[] }) {
    return (
        <ol className="flex flex-col">
            {entries.map((entry, index) => (
                <li key={entry.id} className="flex gap-4">
                    <div className="flex flex-col items-center">
                        <span
                            className={[
                                "mt-1.5 size-2.5 rounded-full",
                                entry.status === "now" ? "bg-success" : entry.status === "done" ? "bg-border" : "bg-accent",
                            ].join(" ")}
                            aria-hidden
                        />
                        {index < entries.length - 1 && <span className="w-px flex-1 bg-separator" aria-hidden />}
                    </div>
                    <div className={`flex min-w-0 flex-1 items-start justify-between gap-3 pb-5 ${entry.status === "done" ? "opacity-60" : ""}`}>
                        <div className="min-w-0">
                            <p className="text-xs font-medium text-muted tabular-nums">{entry.time}</p>
                            <p className="truncate font-medium">{entry.title}</p>
                            <p className="truncate text-sm text-muted">
                                {entry.subtitle}
                                {entry.room ? ` · ${entry.room}` : ""}
                            </p>
                        </div>
                        {entry.status && (
                            <Chip size="sm" variant="soft" color={STATUS_COLOR[entry.status]}>
                                {STATUS_LABEL[entry.status]}
                            </Chip>
                        )}
                    </div>
                </li>
            ))}
        </ol>
    );
}
