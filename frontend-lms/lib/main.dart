import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app/app_scope.dart';
import 'app/router.dart';
import 'app/theme/hero_theme.dart';
import 'core/api/api_client.dart';
import 'core/auth/auth_controller.dart';
import 'core/services/qr_login_service.dart';
import 'core/services/school_service.dart';

void main() {
  runApp(const TafakkurApp());
}

class TafakkurApp extends StatefulWidget {
  const TafakkurApp({super.key});

  @override
  State<TafakkurApp> createState() => _TafakkurAppState();
}

class _TafakkurAppState extends State<TafakkurApp> {
  final _api = ApiClient();
  late final _auth = AuthController(_api);
  late final _school = SchoolService(_api, _auth);
  late final _qrLogin = QrLoginService(_api);
  final _themeMode = ValueNotifier(ThemeMode.system);
  late final GoRouter _router = buildRouter(_auth);

  @override
  void dispose() {
    _router.dispose();
    _auth.dispose();
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      auth: _auth,
      school: _school,
      qrLogin: _qrLogin,
      themeMode: _themeMode,
      child: ValueListenableBuilder(
        valueListenable: _themeMode,
        builder: (context, mode, _) => MaterialApp.router(
          title: 'Tafakkur LMS',
          debugShowCheckedModeBanner: false,
          theme: buildHeroTheme(Brightness.light),
          darkTheme: buildHeroTheme(Brightness.dark),
          themeMode: mode,
          routerConfig: _router,
        ),
      ),
    );
  }
}
