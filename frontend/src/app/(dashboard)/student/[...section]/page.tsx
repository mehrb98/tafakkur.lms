import { ComingSoon } from "@/components/coming-soon/ComingSoon";

export default async function StudentSectionPage({ params }: PageProps<"/student/[...section]">) {
    const { section } = await params;
    return <ComingSoon section={section.at(-1) ?? "student"} backHref="/student" />;
}
