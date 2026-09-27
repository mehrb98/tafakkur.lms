import { keepPreviousData, useQuery } from "@tanstack/react-query";
import type { ListParams } from "@/types/api";
import { listTeachers } from "../services/teachers.service";

export function useTeachers(params: ListParams) {
    return useQuery({
        queryKey: ["teachers", params],
        queryFn: () => listTeachers(params),
        placeholderData: keepPreviousData,
    });
}
