"use client";

import type { ReactNode } from "react";
import { Card, Label, Pagination, SearchField, Spinner, Table } from "@heroui/react";
import type { PaginationMeta } from "@/types/api";

export interface DataColumn<T> {
    id: string;
    header: string;
    cell: (item: T) => ReactNode;
    isRowHeader?: boolean;
    className?: string;
}

interface DataTableProps<T extends { id: string }> {
    ariaLabel: string;
    columns: DataColumn<T>[];
    items: T[];
    meta?: PaginationMeta;
    isLoading: boolean;
    error?: Error | null;
    search: string;
    onSearchChange: (value: string) => void;
    searchPlaceholder: string;
    onPageChange: (page: number) => void;
    toolbar?: ReactNode;
}

function pageWindow(current: number, total: number): (number | "gap")[] {
    if (total <= 7) {
        return Array.from({ length: total }, (_, index) => index + 1);
    }
    const pages = new Set([1, total, current - 1, current, current + 1]);
    const sorted = [...pages].filter((page) => page >= 1 && page <= total).sort((a, b) => a - b);
    return sorted.flatMap((page, index) => (index > 0 && page - sorted[index - 1] > 1 ? ["gap" as const, page] : [page]));
}

export function DataTable<T extends { id: string }>({
    ariaLabel,
    columns,
    items,
    meta,
    isLoading,
    error,
    search,
    onSearchChange,
    searchPlaceholder,
    onPageChange,
    toolbar,
}: DataTableProps<T>) {
    const page = meta?.page ?? 1;
    const totalPages = meta?.total_pages ?? 1;

    return (
        <Card className="gap-0 overflow-hidden p-0">
            <div className="flex flex-col gap-3 border-b border-separator p-4 sm:flex-row sm:items-center sm:justify-between">
                <SearchField value={search} onChange={onSearchChange} className="w-full sm:max-w-xs">
                    <Label className="sr-only">{searchPlaceholder}</Label>
                    <SearchField.Group>
                        <SearchField.SearchIcon />
                        <SearchField.Input placeholder={searchPlaceholder} />
                        <SearchField.ClearButton />
                    </SearchField.Group>
                </SearchField>
                <div className="flex items-center gap-2">
                    {isLoading && <Spinner size="sm" aria-label="Loading" />}
                    {toolbar}
                </div>
            </div>

            <Table variant="secondary" className="rounded-none">
                <Table.ScrollContainer>
                    <Table.Content aria-label={ariaLabel} className="min-w-[640px]">
                        <Table.Header>
                            {columns.map((column) => (
                                <Table.Column key={column.id} id={column.id} isRowHeader={column.isRowHeader} className={column.className}>
                                    {column.header}
                                </Table.Column>
                            ))}
                        </Table.Header>
                        <Table.Body
                            items={items}
                            renderEmptyState={() => (
                                <div className="py-12 text-center text-sm text-muted">
                                    {error ? `Couldn't load data: ${error.message}` : isLoading ? "Loading…" : "No records found."}
                                </div>
                            )}
                        >
                            {(item) => (
                                <Table.Row id={item.id}>
                                    {columns.map((column) => (
                                        <Table.Cell key={column.id} className={column.className}>
                                            {column.cell(item)}
                                        </Table.Cell>
                                    ))}
                                </Table.Row>
                            )}
                        </Table.Body>
                    </Table.Content>
                </Table.ScrollContainer>
            </Table>

            <div className="flex flex-col items-center justify-between gap-3 border-t border-separator p-4 sm:flex-row">
                <p className="whitespace-nowrap text-sm text-muted">
                    {meta ? `${meta.total} total · page ${page} of ${totalPages}` : " "}
                </p>
                <Pagination size="sm">
                    <Pagination.Content>
                        <Pagination.Item>
                            <Pagination.Previous isDisabled={page <= 1} onPress={() => onPageChange(page - 1)}>
                                <Pagination.PreviousIcon />
                                <span className="hidden sm:inline">Previous</span>
                            </Pagination.Previous>
                        </Pagination.Item>
                        {pageWindow(page, totalPages).map((entry, index) =>
                            entry === "gap" ? (
                                <Pagination.Item key={`gap-${index}`}>
                                    <Pagination.Ellipsis />
                                </Pagination.Item>
                            ) : (
                                <Pagination.Item key={entry}>
                                    <Pagination.Link isActive={entry === page} onPress={() => onPageChange(entry)}>
                                        {entry}
                                    </Pagination.Link>
                                </Pagination.Item>
                            ),
                        )}
                        <Pagination.Item>
                            <Pagination.Next isDisabled={page >= totalPages} onPress={() => onPageChange(page + 1)}>
                                <span className="hidden sm:inline">Next</span>
                                <Pagination.NextIcon />
                            </Pagination.Next>
                        </Pagination.Item>
                    </Pagination.Content>
                </Pagination>
            </div>
        </Card>
    );
}
