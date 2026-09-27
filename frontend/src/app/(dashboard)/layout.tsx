import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { Sidebar } from "@/layout/sidebar/Sidebar";
import { SidebarProvider } from "@/layout/sidebar/SidebarContext";
import { TopBar } from "@/layout/top-bar/TopBar";
import { ROLE_COOKIE } from "@/lib/auth/session";
import { isRole } from "@/types/api";

export default async function DashboardLayout({ children }: LayoutProps<"/">) {
    const role = (await cookies()).get(ROLE_COOKIE)?.value;
    if (!isRole(role)) {
        redirect("/auth/login");
    }

    return (
        <SidebarProvider>
            <div className="flex min-h-dvh bg-background">
                <a
                    href="#main"
                    className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-50 focus:rounded-lg focus:bg-surface focus:px-4 focus:py-2"
                >
                    Skip to content
                </a>
                <Sidebar role={role} />
                <div className="flex min-w-0 flex-1 flex-col">
                    <TopBar role={role} />
                    <main id="main" className="flex-1 px-4 py-6 sm:px-6 lg:px-8">
                        <div className="mx-auto w-full max-w-7xl">{children}</div>
                    </main>
                </div>
            </div>
        </SidebarProvider>
    );
}
