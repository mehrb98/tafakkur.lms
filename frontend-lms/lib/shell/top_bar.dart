import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/theme/hero_colors.dart';
import '../core/models/models.dart';
import '../core/navigation/nav_items.dart';
import '../widgets/hero_widgets.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.role,
    required this.location,
    this.onMenu,
    this.onToggleSidebar,
    this.isSidebarCollapsed = false,
  });

  final Role role;
  final String location;
  final VoidCallback? onMenu;
  final VoidCallback? onToggleSidebar;
  final bool isSidebarCollapsed;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    final scope = AppScope.of(context);
    final user = scope.auth.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: hero.background,
        border: Border(bottom: BorderSide(color: hero.separator)),
      ),
      child: Row(
        children: [
          if (onMenu != null)
            IconButton(tooltip: 'Open navigation', icon: const Icon(Icons.menu_rounded), onPressed: onMenu),
          if (onToggleSidebar != null)
            IconButton(
              tooltip: isSidebarCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
              icon: Icon(isSidebarCollapsed ? Icons.menu_rounded : Icons.menu_open_rounded, size: 20),
              onPressed: onToggleSidebar,
            ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              activeItem(role, location)?.label ?? 'Dashboard',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (scope.auth.isDemo && MediaQuery.sizeOf(context).width >= 600) ...[
            const SizedBox(width: 8),
            const HeroChip('Demo data', tone: Tone.warning),
          ],
          const Spacer(),
          if (wide)
            const SizedBox(
              width: 260,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search students, classes…',
                  prefixIcon: Icon(Icons.search_rounded, size: 18),
                  prefixIconConstraints: BoxConstraints(minWidth: 40),
                ),
              ),
            ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: isDark ? 'Switch to light theme' : 'Switch to dark theme',
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 20),
            onPressed: () => scope.themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark,
          ),
          IconButton(
            tooltip: 'Notifications, 3 unread',
            icon: Badge(
              label: const Text('3'),
              backgroundColor: hero.danger,
              child: const Icon(Icons.notifications_none_rounded, size: 21),
            ),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            tooltip: 'Account menu',
            position: PopupMenuPosition.under,
            onSelected: (value) {
              if (value == 'logout') scope.auth.signOut();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? '',
                      style: TextStyle(fontWeight: FontWeight.w500, color: hero.foreground, fontSize: 14),
                    ),
                    Text(user?.email ?? '', style: TextStyle(fontSize: 12, color: hero.muted)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              _item('profile', Icons.person_outline, 'Profile', hero.foreground),
              _item('settings', Icons.settings_outlined, 'Settings', hero.foreground),
              _item('logout', Icons.logout_rounded, 'Sign out', hero.danger),
            ],
            child: Padding(padding: const EdgeInsets.only(left: 4), child: HeroAvatar(user?.initials ?? '')),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _item(String value, IconData icon, String label, Color color) => PopupMenuItem(
    value: value,
    height: 40,
    child: Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: color, fontSize: 14)),
      ],
    ),
  );
}
