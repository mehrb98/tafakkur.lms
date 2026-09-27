import type { Metadata } from "next";
import { Inter } from "next/font/google";
import { Providers } from "@/providers/Providers";
import "./globals.css";

const inter = Inter({
    variable: "--font-inter",
    subsets: ["latin", "cyrillic"],
});

export const metadata: Metadata = {
    title: {
        default: "Tafakkur LMS",
        template: "%s · Tafakkur LMS",
    },
    description: "Learning management system for schools",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
    return (
        <html lang="en" className={`${inter.variable} antialiased`} suppressHydrationWarning>
            <body>
                <Providers>{children}</Providers>
            </body>
        </html>
    );
}
