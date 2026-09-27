import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/theme/hero_colors.dart';
import 'sidebar.dart';
import 'top_bar.dart';

/// Dashboard chrome: a collapsible sidebar on wide screens, a drawer on phones.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    final user = AppScope.of(context).auth.user;
    if (user == null) return const SizedBox.shrink();

    final wide = MediaQuery.sizeOf(context).width >= 1024;
    final content = Column(
      children: [
        TopBar(
          role: user.role,
          location: widget.location,
          onMenu: wide ? null : () => _scaffoldKey.currentState?.openDrawer(),
          isSidebarCollapsed: _collapsed,
          onToggleSidebar: wide ? () => setState(() => _collapsed = !_collapsed) : null,
        ),
        Expanded(child: widget.child),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: wide
          ? null
          : Drawer(
              shape: const RoundedRectangleBorder(),
              child: SafeArea(
                child: Sidebar(
                  role: user.role,
                  location: widget.location,
                  onNavigate: () => Navigator.of(context).pop(),
                ),
              ),
            ),
      body: SafeArea(
        child: wide
            ? Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: _collapsed ? 76 : 256,
                    decoration: BoxDecoration(
                      color: hero.surface,
                      border: Border(right: BorderSide(color: hero.separator)),
                    ),
                    child: Sidebar(role: user.role, location: widget.location, compact: _collapsed),
                  ),
                  Expanded(child: content),
                ],
              )
            : content,
      ),
    );
  }
}
