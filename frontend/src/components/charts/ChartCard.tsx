import type { ReactNode } from "react";
import { Card } from "@heroui/react";

interface ChartCardProps {
    title: string;
    description?: string;
    action?: ReactNode;
    children: ReactNode;
    className?: string;
}

export function ChartCard({ title, description, action, children, className }: ChartCardProps) {
    return (
        <Card className={`gap-4 p-5 ${className ?? ""}`}>
            <Card.Header className="flex flex-row items-start justify-between gap-3 p-0">
                <div className="min-w-0">
                    <Card.Title className="text-base font-semibold">{title}</Card.Title>
                    {description && <Card.Description className="text-sm text-muted">{description}</Card.Description>}
                </div>
                {action}
            </Card.Header>
            <Card.Content className="p-0">{children}</Card.Content>
        </Card>
    );
}
