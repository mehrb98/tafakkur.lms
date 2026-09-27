import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme/hero_colors.dart';
import '../../app/theme/hero_theme.dart';
import '../../core/api/api_client.dart';
import '../../core/models/models.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _rememberMe = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AppScope.of(context).auth.signIn(_email.text.trim(), _password.text, rememberMe: _rememberMe);
    } on ApiException catch (error) {
      setState(() => _error = error.status == 401 ? 'Email or password is incorrect.' : error.message);
    } on Exception {
      setState(() => _error = "Couldn't reach the server. Check that the API is running, or explore the demo below.");
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    final wide = MediaQuery.sizeOf(context).width >= 1024;
    final form = _form(context, hero);

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: hero.accent,
                            borderRadius: BorderRadius.circular(HeroRadius.item),
                          ),
                          child: Icon(Icons.school_rounded, size: 20, color: hero.accentForeground),
                        ),
                        const SizedBox(width: 12),
                        const Text('Tafakkur LMS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 384), child: form),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (wide)
            Expanded(
              child: Container(
                color: hero.accent,
                padding: const EdgeInsets.all(48),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One place for classes, grades, attendance and families.',
                      style: TextStyle(
                        fontSize: 30,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: hero.accentForeground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Administrators, teachers, students and parents each get a dashboard built for what they do every day.',
                      style: TextStyle(fontSize: 14, color: hero.accentForeground.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text.rich(
      TextSpan(
        text: text,
        children: [
          TextSpan(
            text: ' *',
            style: TextStyle(color: context.hero.danger),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );

  Widget _form(BuildContext context, HeroColors hero) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.4),
            ),
            const SizedBox(height: 4),
            Text('Sign in with your school account.', style: TextStyle(fontSize: 14, color: hero.muted)),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hero.soft(hero.danger),
                  borderRadius: BorderRadius.circular(HeroRadius.field),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 18, color: hero.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!, style: TextStyle(fontSize: 14, color: hero.softForeground(hero.danger))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            _label('Email'),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(hintText: 'you@school.uz'),
              validator: (value) => value == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())
                  ? 'Enter a valid email'
                  : null,
            ),
            const SizedBox(height: 16),
            _label('Password'),
            TextFormField(
              controller: _password,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: const InputDecoration(hintText: '••••••••'),
              validator: (value) => value == null || value.isEmpty ? 'Enter your password' : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _rememberMe,
              onChanged: (value) => setState(() => _rememberMe = value ?? true),
              title: const Text('Keep me signed in', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: hero.accentForeground),
                    )
                  : const Text('Sign in'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider()),
                Flexible(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or explore with sample data',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: hero.muted),
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 4.4,
              children: [
                for (final role in Role.values)
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: hero.defaultColor,
                      foregroundColor: hero.softForeground(hero.accent),
                    ),
                    onPressed: () => AppScope.of(context).auth.signInDemo(role),
                    child: Text(role.label),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
