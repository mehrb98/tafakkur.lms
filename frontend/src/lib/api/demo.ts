import type { ApiUser, ListParams, PaginatedResponse, Role } from "@/types/api";

const FIRST_NAMES = ["Malika", "Jasur", "Dilnoza", "Sardor", "Nodira", "Bekzod", "Gulnora", "Aziz", "Madina", "Otabek", "Kamola", "Sherzod", "Zarina", "Rustam", "Laylo", "Timur"];
const LAST_NAMES = ["Yusupova", "Rahimov", "Karimova", "Tursunov", "Saidova", "Aliyev", "Nazarova", "Ergashev", "Qodirova", "Mirzayev"];

export function demoPerson(index: number, role: Role): ApiUser {
    const first = FIRST_NAMES[index % FIRST_NAMES.length];
    const last = LAST_NAMES[(index * 7) % LAST_NAMES.length];
    return {
        id: `demo-${role}-${index}`,
        email: `${first}.${last}${index}@demo.tafakkur.uz`.toLowerCase(),
        first_name: first,
        last_name: last,
        role,
        school_id: "demo-school",
        phone: `+998 90 ${String(1000000 + index * 7919).slice(0, 3)} ${String(1000 + index * 37).slice(-4)}`,
        avatar_url: null,
        email_verified: index % 5 !== 0,
    };
}

/** Paginates and searches an in-memory list the way the Rails index endpoints do. */
export function paginateDemo<T>(all: T[], params: ListParams, matches: (item: T, q: string) => boolean): PaginatedResponse<T> {
    const page = params.page ?? 1;
    const limit = params.limit ?? 25;
    const q = params.q?.trim().toLowerCase() ?? "";
    const filtered = q ? all.filter((item) => matches(item, q)) : all;
    const start = (page - 1) * limit;
    return {
        data: filtered.slice(start, start + limit),
        meta: { page, limit, total: filtered.length, total_pages: Math.max(1, Math.ceil(filtered.length / limit)) },
    };
}

export function delay(ms = 250): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
}
