import { keepPreviousData, useQuery } from "@tanstack/react-query";
import type { ListParams } from "@/types/api";
import { listStudents } from "../services/students.service";

export function useStudents(params: ListParams) {
    return useQuery({
        queryKey: ["students", params],
        queryFn: () => listStudents(params),
        placeholderData: keepPreviousData,
    });
}
