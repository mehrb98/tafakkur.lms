"use client";

import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";

interface BarsChartProps<T extends object> {
    data: T[];
    xKey: string;
    yKey: string;
    label: string;
    color?: string;
    unit?: string;
}

export function BarsChart<T extends object>({ data, xKey, yKey, label, color = "var(--accent)", unit }: BarsChartProps<T>) {
    return (
        <div className="h-64 w-full" role="img" aria-label={label}>
            <ResponsiveContainer width="100%" height="100%">
                <BarChart data={data} margin={{ top: 8, right: 8, left: -16, bottom: 0 }}>
                    <CartesianGrid vertical={false} stroke="var(--separator)" />
                    <XAxis dataKey={xKey} tickLine={false} axisLine={false} tick={{ fill: "var(--muted)", fontSize: 12 }} />
                    <YAxis unit={unit} tickLine={false} axisLine={false} tick={{ fill: "var(--muted)", fontSize: 12 }} />
                    <Tooltip
                        cursor={{ fill: "var(--default)", opacity: 0.6 }}
                        contentStyle={{
                            background: "var(--overlay)",
                            border: "1px solid var(--border)",
                            borderRadius: 12,
                            color: "var(--overlay-foreground)",
                        }}
                    />
                    <Bar dataKey={yKey} name={label} fill={color} radius={[6, 6, 0, 0]} maxBarSize={36} />
                </BarChart>
            </ResponsiveContainer>
        </div>
    );
}
