import { ComingSoon } from "@/components/coming-soon/ComingSoon";

export default async function ParentSectionPage({ params }: PageProps<"/parent/[...section]">) {
    const { section } = await params;
    return <ComingSoon section={section.at(-1) ?? "parent"} backHref="/parent" />;
}
