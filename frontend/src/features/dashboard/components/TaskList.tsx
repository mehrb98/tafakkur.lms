import { Chip } from "@heroui/react";
import type { TaskEntry } from "../types/dashboard.types";

export function TaskList({ tasks }: { tasks: TaskEntry[] }) {
    return (
        <ul className="-mx-2 flex flex-col">
            {tasks.map((task) => (
                <li key={task.id} className="flex items-center justify-between gap-3 rounded-xl px-2 py-2.5 hover:bg-default-soft">
                    <div className="min-w-0">
                        <p className="truncate text-sm font-medium">{task.title}</p>
                        <p className="truncate text-xs text-muted">{task.subtitle}</p>
                    </div>
                    <Chip size="sm" variant="soft" color={task.tone}>
                        {task.due}
                    </Chip>
                </li>
            ))}
        </ul>
    );
}
