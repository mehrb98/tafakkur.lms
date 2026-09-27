import { GraduationCap } from "@gravity-ui/icons";

export default function AuthLayout({ children }: LayoutProps<"/auth">) {
    return (
        <div className="grid min-h-dvh lg:grid-cols-2">
            <div className="flex flex-col px-6 py-8 sm:px-10">
                <div className="flex items-center gap-3">
                    <div className="flex size-9 items-center justify-center rounded-xl bg-accent text-accent-foreground">
                        <GraduationCap className="size-5" aria-hidden />
                    </div>
                    <span className="text-sm font-semibold">Tafakkur LMS</span>
                </div>
                <main className="flex flex-1 items-center justify-center py-10">
                    <div className="w-full max-w-sm">{children}</div>
                </main>
            </div>
            <aside className="relative hidden overflow-hidden bg-accent lg:block" aria-hidden>
                <div className="absolute -right-24 -top-24 size-96 rounded-full bg-white/10" />
                <div className="absolute -bottom-32 -left-16 size-[28rem] rounded-full bg-white/10" />
                <div className="relative flex h-full flex-col justify-end p-12 text-accent-foreground">
                    <p className="text-3xl font-semibold leading-tight">
                        One place for classes, grades, attendance and families.
                    </p>
                    <p className="mt-3 max-w-md text-sm opacity-80">
                        Administrators, teachers, students and parents each get a dashboard built for what they do every day.
                    </p>
                </div>
            </aside>
        </div>
    );
}
