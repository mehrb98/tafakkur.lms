import { ComingSoon } from "@/components/coming-soon/ComingSoon";

export default async function AdminSectionPage({ params }: PageProps<"/admin/[...section]">) {
    const { section } = await params;
    return <ComingSoon section={section.at(-1) ?? "admin"} backHref="/admin" />;
}
