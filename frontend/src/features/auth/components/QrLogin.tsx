"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { QRCodeSVG } from "qrcode.react";
import { Button, Skeleton, Spinner } from "@heroui/react";
import { CircleCheck, GraduationCap } from "@gravity-ui/icons";
import { useAuth } from "@/providers/AuthProvider";
import { pollQrLogin, qrLoginUri, startQrLogin } from "../services/auth.service";
import type { QrLoginStart } from "../types/auth.types";

const POLL_INTERVAL_MS = 2000;

type View =
    | { kind: "loading" }
    | { kind: "waiting"; request: QrLoginStart; scanned: boolean }
    | { kind: "signing-in" }
    | { kind: "declined" }
    | { kind: "error" };

/**
 * Telegram-style sign-in: show a QR code, let a signed-in phone approve it,
 * and poll until the API hands this browser a session.
 */
export function QrLogin() {
    const { signIn } = useAuth();
    const [view, setView] = useState<View>({ kind: "loading" });
    const pollSecret = useRef<string | null>(null);
    const expiresAt = useRef(0);

    const start = useCallback(async () => {
        setView({ kind: "loading" });
        try {
            const request = await startQrLogin();
            pollSecret.current = request.poll_secret;
            expiresAt.current = Date.parse(request.expires_at);
            setView({ kind: "waiting", request, scanned: false });
        } catch {
            pollSecret.current = null;
            setView({ kind: "error" });
        }
    }, []);

    useEffect(() => {
        // eslint-disable-next-line react-hooks/set-state-in-effect -- kicks off the first request on mount
        void start();
    }, [start]);

    const isWaiting = view.kind === "waiting";

    useEffect(() => {
        if (!isWaiting) {
            return;
        }
        let cancelled = false;
        const timer = setInterval(async () => {
            const secret = pollSecret.current;
            if (!secret || document.hidden) {
                return;
            }
            if (expiresAt.current < Date.now()) {
                void start();
                return;
            }
            try {
                const result = await pollQrLogin(secret);
                if (cancelled || secret !== pollSecret.current) {
                    return;
                }
                if (result.status === undefined) {
                    pollSecret.current = null;
                    setView({ kind: "signing-in" });
                    signIn(result.user, { accessToken: result.access_token, demo: false });
                } else if (result.status === "scanned") {
                    setView((current) => (current.kind === "waiting" ? { ...current, scanned: true } : current));
                } else if (result.status === "declined") {
                    pollSecret.current = null;
                    setView({ kind: "declined" });
                } else if (result.status === "expired" || result.status === "consumed") {
                    void start();
                }
            } catch {
                // Transient network error: keep polling until the code expires.
            }
        }, POLL_INTERVAL_MS);

        return () => {
            cancelled = true;
            clearInterval(timer);
        };
    }, [isWaiting, signIn, start]);

    return (
        <div className="flex flex-col items-center gap-6">
            <div className="relative flex size-60 items-center justify-center rounded-3xl bg-white p-4 shadow-sm ring-1 ring-black/5">
                {view.kind === "loading" && <Skeleton className="size-full rounded-2xl" />}
                {view.kind === "waiting" && (
                    <QRCodeSVG
                        value={qrLoginUri(view.request.qr_token)}
                        size={208}
                        level="M"
                        marginSize={0}
                        fgColor="#18181b"
                        bgColor="#ffffff"
                        title="QR code for signing in with the Tafakkur mobile app"
                        className={view.scanned ? "opacity-15 blur-[2px] transition" : "transition"}
                    />
                )}
                {view.kind === "waiting" && !view.scanned && (
                    <div className="absolute flex size-11 items-center justify-center rounded-xl bg-accent text-accent-foreground ring-4 ring-white" aria-hidden>
                        <GraduationCap className="size-6" />
                    </div>
                )}
                {view.kind === "waiting" && view.scanned && (
                    <div className="absolute inset-0 flex flex-col items-center justify-center gap-2 text-center text-zinc-900" role="status">
                        <CircleCheck className="size-8 text-success" aria-hidden />
                        <p className="px-6 text-sm font-medium">Scanned. Confirm the sign-in on your phone.</p>
                    </div>
                )}
                {view.kind === "signing-in" && <Spinner aria-label="Signing in" />}
                {(view.kind === "declined" || view.kind === "error") && (
                    <div className="flex flex-col items-center gap-3 text-center text-zinc-900" role="alert">
                        <p className="text-sm">
                            {view.kind === "declined" ? "The sign-in was declined on the phone." : "Couldn't create a QR code. Is the API running?"}
                        </p>
                        <Button size="sm" onPress={() => void start()}>
                            Get a new code
                        </Button>
                    </div>
                )}
            </div>

            <ol className="flex w-full flex-col gap-3 text-sm">
                {[
                    "Open the Tafakkur app on your phone and sign in",
                    "Tap the QR icon at the top of the dashboard",
                    "Point your phone at this screen and confirm",
                ].map((step, index) => (
                    <li key={step} className="flex items-center gap-3">
                        <span className="flex size-6 shrink-0 items-center justify-center rounded-full bg-accent-soft text-xs font-semibold text-accent-soft-foreground">
                            {index + 1}
                        </span>
                        <span>{step}</span>
                    </li>
                ))}
            </ol>
        </div>
    );
}
