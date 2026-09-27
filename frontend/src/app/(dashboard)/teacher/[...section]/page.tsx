import { ComingSoon } from "@/components/coming-soon/ComingSoon";

export default async function TeacherSectionPage({ params }: PageProps<"/teacher/[...section]">) {
    const { section } = await params;
    return <ComingSoon section={section.at(-1) ?? "teacher"} backHref="/teacher" />;
}
