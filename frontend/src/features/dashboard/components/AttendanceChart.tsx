"use client";

import { Area, AreaChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import type { AttendancePoint } from "../types/dashboard.types";

export function AttendanceChart({ data }: { data: AttendancePoint[] }) {
    return (
        <div className="h-64 w-full" role="img" aria-label="Attendance rate by day of the week">
            <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={data} margin={{ top: 8, right: 8, left: -16, bottom: 0 }}>
                    <defs>
                        <linearGradient id="attendanceFill" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="0%" stopColor="var(--accent)" stopOpacity={0.35} />
                            <stop offset="100%" stopColor="var(--accent)" stopOpacity={0} />
                        </linearGradient>
                    </defs>
                    <CartesianGrid vertical={false} stroke="var(--separator)" />
                    <XAxis dataKey="day" tickLine={false} axisLine={false} tick={{ fill: "var(--muted)", fontSize: 12 }} />
                    <YAxis domain={[80, 100]} unit="%" tickLine={false} axisLine={false} tick={{ fill: "var(--muted)", fontSize: 12 }} />
                    <Tooltip
                        cursor={{ stroke: "var(--border)" }}
                        contentStyle={{
                            background: "var(--overlay)",
                            border: "1px solid var(--border)",
                            borderRadius: 12,
                            color: "var(--overlay-foreground)",
                        }}
                        formatter={(value) => [`${String(value)}%`, "Present"]}
                    />
                    <Area type="monotone" dataKey="present" stroke="var(--accent)" strokeWidth={2} fill="url(#attendanceFill)" />
                </AreaChart>
            </ResponsiveContainer>
        </div>
    );
}
