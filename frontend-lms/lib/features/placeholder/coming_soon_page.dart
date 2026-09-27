import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme/hero_colors.dart';
import '../../widgets/hero_widgets.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.section});

  final String section;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    final title = section.replaceAll('-', ' ');
    final role = AppScope.of(context).auth.user?.role.name ?? '';
    return PageBody(
      children: [
        HeroCard(
          padding: 40,
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: hero.soft(hero.accent), borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.layers_outlined, color: hero.softForeground(hero.accent)),
              ),
              const SizedBox(height: 12),
              Text(
                title[0].toUpperCase() + title.substring(1),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                "This section is part of the navigation but its screen isn't built yet.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: hero.muted),
              ),
              TextButton(onPressed: () => context.go('/$role'), child: const Text('Back to dashboard')),
            ],
          ),
        ),
      ],
    );
  }
}
