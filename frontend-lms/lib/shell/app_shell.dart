import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import 'sidebar.dart';
import 'top_bar.dart';

/// Dashboard chrome for phones and tablets: the sidebar lives in a drawer
/// opened from the top bar (or by swiping from the left edge).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).auth.user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      drawer: Drawer(
        shape: const RoundedRectangleBorder(),
        child: SafeArea(
          child: Builder(
            builder: (context) =>
                Sidebar(role: user.role, location: location, onNavigate: () => Scaffold.of(context).closeDrawer()),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Builder(
              builder: (context) =>
                  TopBar(role: user.role, location: location, onMenu: () => Scaffold.of(context).openDrawer()),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
