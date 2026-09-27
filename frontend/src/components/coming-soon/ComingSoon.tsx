import Link from "next/link";
import { Card, EmptyState } from "@heroui/react";
import { Layers } from "@gravity-ui/icons";

interface ComingSoonProps {
    section: string;
    backHref: string;
}

function titleCase(slug: string): string {
    const words = slug.replace(/-/g, " ");
    return words.charAt(0).toUpperCase() + words.slice(1);
}

export function ComingSoon({ section, backHref }: ComingSoonProps) {
    return (
        <Card className="p-10">
            <EmptyState className="flex flex-col items-center gap-3 text-center">
                <div className="flex size-12 items-center justify-center rounded-2xl bg-accent-soft text-accent-soft-foreground">
                    <Layers className="size-6" aria-hidden />
                </div>
                <h2 className="text-lg font-semibold">{titleCase(section)}</h2>
                <p className="max-w-sm text-sm text-muted">
                    This section is part of the navigation but its screen isn&apos;t built yet.
                </p>
                <Link href={backHref} className="text-sm font-medium text-accent hover:underline">
                    Back to dashboard
                </Link>
            </EmptyState>
        </Card>
    );
}
