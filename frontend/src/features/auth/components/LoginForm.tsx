"use client";

import { useState, type FormEvent } from "react";
import { Alert, Button, Checkbox, FieldError, Form, Input, Label, Separator, TextField } from "@heroui/react";
import { ApiError } from "@/lib/api/client";
import { useAuth } from "@/providers/AuthProvider";
import { ROLE_LABELS } from "@/lib/navigation/nav";
import { ROLES, type Role } from "@/types/api";
import { demoUser, login } from "../services/auth.service";

export function LoginForm() {
    const { signIn } = useAuth();
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [rememberMe, setRememberMe] = useState(true);
    const [isSubmitting, setSubmitting] = useState(false);
    const [error, setError] = useState<string | null>(null);

    async function handleSubmit(event: FormEvent<HTMLFormElement>) {
        event.preventDefault();
        setSubmitting(true);
        setError(null);
        try {
            const result = await login({ email, password, remember_me: rememberMe });
            signIn(result.user, { accessToken: result.access_token, demo: false });
        } catch (caught) {
            if (caught instanceof ApiError) {
                setError(caught.status === 401 ? "Email or password is incorrect." : caught.message);
            } else {
                setError("Couldn't reach the server. Check that the API is running, or explore the demo below.");
            }
            setSubmitting(false);
        }
    }

    function enterDemo(role: Role) {
        signIn(demoUser(role), { demo: true });
    }

    return (
        <div className="flex flex-col gap-6">
            <div>
                <h1 className="text-2xl font-semibold tracking-tight">Welcome back</h1>
                <p className="mt-1 text-sm text-muted">Sign in with your school account.</p>
            </div>

            {error && (
                <Alert status="danger">
                    <Alert.Indicator />
                    <Alert.Content>
                        <Alert.Description>{error}</Alert.Description>
                    </Alert.Content>
                </Alert>
            )}

            <Form className="flex flex-col gap-4" onSubmit={handleSubmit}>
                <TextField name="email" type="email" isRequired value={email} onChange={setEmail} autoComplete="email">
                    <Label>Email</Label>
                    <Input placeholder="you@school.uz" />
                    <FieldError />
                </TextField>
                <TextField name="password" type="password" isRequired value={password} onChange={setPassword} autoComplete="current-password">
                    <Label>Password</Label>
                    <Input placeholder="••••••••" />
                    <FieldError />
                </TextField>
                <Checkbox isSelected={rememberMe} onChange={setRememberMe}>
                    <Checkbox.Content>
                        <Checkbox.Control>
                            <Checkbox.Indicator />
                        </Checkbox.Control>
                        <Label>Keep me signed in</Label>
                    </Checkbox.Content>
                </Checkbox>
                <Button type="submit" fullWidth isPending={isSubmitting}>
                    {isSubmitting ? "Signing in…" : "Sign in"}
                </Button>
            </Form>

            <div className="flex items-center gap-3">
                <Separator className="flex-1" />
                <span className="text-xs text-muted">or explore with sample data</span>
                <Separator className="flex-1" />
            </div>

            <div className="grid grid-cols-2 gap-2">
                {ROLES.map((role) => (
                    <Button key={role} variant="secondary" fullWidth onPress={() => enterDemo(role)}>
                        {ROLE_LABELS[role]}
                    </Button>
                ))}
            </div>
        </div>
    );
}
