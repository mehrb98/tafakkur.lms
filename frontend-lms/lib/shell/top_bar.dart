import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/app_scope.dart';
import '../app/theme/hero_colors.dart';
import '../core/models/models.dart';
import '../core/navigation/nav_items.dart';
import '../widgets/hero_widgets.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.role, required this.location, required this.onMenu});

  final Role role;
  final String location;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    final scope = AppScope.of(context);
    final user = scope.auth.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: hero.background,
        border: Border(bottom: BorderSide(color: hero.separator)),
      ),
      child: Row(
        children: [
          IconButton(tooltip: 'Open navigation', icon: const Icon(Icons.menu_rounded), onPressed: onMenu),
          Expanded(
            child: Text(
              activeItem(role, location)?.label ?? 'Dashboard',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Scan QR code to sign in on the web',
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
            onPressed: () => context.push('/scan'),
          ),
          IconButton(
            tooltip: 'Notifications, 3 unread',
            icon: Badge(
              label: const Text('3'),
              backgroundColor: hero.danger,
              child: const Icon(Icons.notifications_none_rounded, size: 22),
            ),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            tooltip: 'Account menu',
            position: PopupMenuPosition.under,
            onSelected: (value) {
              switch (value) {
                case 'theme':
                  scope.themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
                case 'logout':
                  scope.auth.signOut();
              }
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
                    if (scope.auth.isDemo) ...[
                      const SizedBox(height: 6),
                      const HeroChip('Demo data', tone: Tone.warning),
                    ],
                  ],
                ),
              ),
              const PopupMenuDivider(),
              _item(
                'theme',
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                isDark ? 'Light theme' : 'Dark theme',
                hero.foreground,
              ),
              _item('logout', Icons.logout_rounded, 'Sign out', hero.danger),
            ],
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: HeroAvatar(user?.initials ?? '')),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _item(String value, IconData icon, String label, Color color) => PopupMenuItem(
    value: value,
    height: 44,
    child: Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: color, fontSize: 14)),
      ],
    ),
  );
}
