import { Chip } from "@heroui/react";

/** Marks widgets backed by sample data because the API has no endpoint for them yet. */
export function SampleDataChip() {
    return (
        <Chip size="sm" variant="soft" color="default">
            Sample
        </Chip>
    );
}
