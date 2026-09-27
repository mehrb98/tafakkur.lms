import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/app_scope.dart';
import '../app/theme/hero_colors.dart';
import '../app/theme/hero_theme.dart';
import '../core/models/models.dart';
import '../core/navigation/nav_items.dart';
import '../widgets/hero_widgets.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key, required this.role, required this.location, this.onNavigate});

  final Role role;
  final String location;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    final user = AppScope.of(context).auth.user;
    final active = activeItem(role, location);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: hero.accent, borderRadius: BorderRadius.circular(HeroRadius.item)),
                  child: Icon(Icons.school_rounded, size: 20, color: hero.accentForeground),
                ),
                ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tafakkur LMS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('School workspace', style: TextStyle(fontSize: 12, color: hero.muted)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            children: [
              for (final section in navigation[role]!) ...[
                if (section.title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
                    child: Text(
                      section.title!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: hero.muted,
                      ),
                    ),
                  ),
                for (final item in section.items)
                  _NavTile(
                    item: item,
                    isActive: active?.path == item.path,
                    onTap: () {
                      onNavigate?.call();
                      context.go(item.path);
                    },
                  ),
              ],
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              HeroAvatar(user?.initials ?? ''),
              ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? '',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(role.label, style: TextStyle(fontSize: 12, color: hero.muted)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.isActive, required this.onTap});

  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    final foreground = isActive ? hero.softForeground(hero.accent) : hero.muted;
    final tile = Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isActive ? hero.soft(hero.accent) : Colors.transparent,
        borderRadius: BorderRadius.circular(HeroRadius.item),
        child: InkWell(
          borderRadius: BorderRadius.circular(HeroRadius.item),
          hoverColor: hero.defaultColor,
          onTap: onTap,
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(item.icon, size: 19, color: foreground),
                ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: foreground),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    return Semantics(selected: isActive, button: true, label: item.label, child: tile);
  }
}
