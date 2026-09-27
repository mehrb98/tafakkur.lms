import { useQuery } from "@tanstack/react-query";
import { fetchSchoolCounts } from "../services/overview.service";

export function useSchoolCounts() {
    return useQuery({ queryKey: ["school-counts"], queryFn: fetchSchoolCounts });
}
