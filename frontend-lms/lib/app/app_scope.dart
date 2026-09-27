import 'package:flutter/material.dart';

import '../core/auth/auth_controller.dart';
import '../core/services/qr_login_service.dart';
import '../core/services/school_service.dart';

/// Hands the app-wide controllers down the tree.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.auth,
    required this.school,
    required this.qrLogin,
    required this.themeMode,
    required super.child,
  });

  final AuthController auth;
  final SchoolService school;
  final QrLoginService qrLogin;
  final ValueNotifier<ThemeMode> themeMode;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in the widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      auth != oldWidget.auth ||
      school != oldWidget.school ||
      qrLogin != oldWidget.qrLogin ||
      themeMode != oldWidget.themeMode;
}
