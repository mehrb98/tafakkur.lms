import { NextResponse, type NextRequest } from "next/server";
import { ROLE_COOKIE } from "@/lib/auth/session";
import { isRole } from "@/types/api";

/**
 * Role-based routing (SAD §6.7). The role cookie is a UX hint set at sign-in;
 * the Rails API (Pundit) remains the authority on what a user may see.
 */
export function proxy(request: NextRequest) {
    const { pathname } = request.nextUrl;
    const roleCookie = request.cookies.get(ROLE_COOKIE)?.value;
    const role = isRole(roleCookie) ? roleCookie : null;

    if (pathname.startsWith("/auth")) {
        if (role && pathname === "/auth/login") {
            return NextResponse.redirect(new URL(`/${role}`, request.url));
        }
        return NextResponse.next();
    }

    if (!role) {
        const loginUrl = new URL("/auth/login", request.url);
        if (pathname !== "/") {
            loginUrl.searchParams.set("next", pathname);
        }
        return NextResponse.redirect(loginUrl);
    }

    if (pathname === "/") {
        return NextResponse.redirect(new URL(`/${role}`, request.url));
    }

    const section = pathname.split("/")[1];
    if (isRole(section) && section !== role) {
        return NextResponse.redirect(new URL(`/${role}`, request.url));
    }

    return NextResponse.next();
}

export const config = {
    matcher: ["/((?!api|_next/static|_next/image|favicon.ico|.*\\.(?:png|jpg|jpeg|svg|webp|ico)$).*)"],
};
