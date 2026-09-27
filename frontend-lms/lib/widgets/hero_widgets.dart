import 'package:flutter/material.dart';

import '../app/theme/hero_colors.dart';
import '../app/theme/hero_theme.dart';

enum Tone { accent, success, warning, danger, neutral }

extension ToneColors on HeroColors {
  Color tone(Tone tone) => switch (tone) {
    Tone.accent => accent,
    Tone.success => success,
    Tone.warning => warning,
    Tone.danger => danger,
    Tone.neutral => muted,
  };
}

/// HeroUI `Chip` with `variant="soft"`.
class HeroChip extends StatelessWidget {
  const HeroChip(this.label, {super.key, this.tone = Tone.accent});

  final String label;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    final color = hero.tone(tone);
    final background = tone == Tone.neutral ? hero.defaultColor : hero.soft(color);
    final foreground = tone == Tone.neutral ? hero.foreground : hero.softForeground(color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

/// HeroUI `Avatar` with a soft fallback tile.
class HeroAvatar extends StatelessWidget {
  const HeroAvatar(this.initials, {super.key, this.tone = Tone.accent, this.size = 32});

  final String initials;
  final Tone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    final color = hero.tone(tone);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: hero.soft(color), shape: BoxShape.circle),
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(color: hero.softForeground(color), fontSize: size * 0.36, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// A HeroUI `Card` with an optional header (title, description, trailing action).
class HeroCard extends StatelessWidget {
  const HeroCard({super.key, this.title, this.description, this.action, required this.child, this.padding = 20});

  final String? title;
  final String? description;
  final Widget? action;
  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        if (description != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(description!, style: TextStyle(fontSize: 14, color: hero.muted)),
                          ),
                      ],
                    ),
                  ),
                  ?action,
                ],
              ),
              const SizedBox(height: 16),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class SampleChip extends StatelessWidget {
  const SampleChip({super.key});

  @override
  Widget build(BuildContext context) => const HeroChip('Sample', tone: Tone.neutral);
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.tone = Tone.accent,
    this.hint,
    this.change,
    this.isUp = true,
  });

  final String label;
  final String? value;
  final IconData icon;
  final Tone tone;
  final String? hint;
  final String? change;
  final bool isUp;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    final color = hero.tone(tone);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(color: hero.muted, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hero.soft(color),
                    borderRadius: BorderRadius.circular(HeroRadius.item),
                  ),
                  child: Icon(icon, size: 20, color: hero.softForeground(color)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: value == null
                      ? Container(
                          height: 32,
                          width: 80,
                          decoration: BoxDecoration(color: hero.defaultColor, borderRadius: BorderRadius.circular(8)),
                        )
                      : Text(
                          value!,
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, letterSpacing: -0.5),
                        ),
                ),
                if (change != null) HeroChip('${isUp ? '▲' : '▼'} $change', tone: isUp ? Tone.success : Tone.danger),
              ],
            ),
            if (hint != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(hint!, style: TextStyle(color: hero.muted, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.4)),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(description!, style: TextStyle(fontSize: 14, color: context.hero.muted)),
            ),
        ],
      ),
    );
  }
}

/// Lays children out in a responsive grid: [columns] across when there is room,
/// fewer on narrow screens. [spans] lets a child take several columns.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key, required this.children, this.columns = 4, this.minItemWidth = 240, this.spans});

  final List<Widget> children;
  final int columns;
  final double minItemWidth;
  final List<int>? spans;

  @override
  Widget build(BuildContext context) {
    const gap = 16.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final fit = ((constraints.maxWidth + gap) / (minItemWidth + gap)).floor().clamp(1, columns);
        final cellWidth = (constraints.maxWidth - gap * (fit - 1)) / fit;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < children.length; i++)
              SizedBox(
                width: () {
                  final span = (fit == columns ? (spans?[i] ?? 1) : 1).clamp(1, fit);
                  return cellWidth * span + gap * (span - 1);
                }(),
                child: children[i],
              ),
          ],
        );
      },
    );
  }
}

/// Scrollable page body with the dashboard's padding and max width.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final horizontal = MediaQuery.sizeOf(context).width >= 640 ? 32.0 : 16.0;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ),
    );
  }
}

const gap = SizedBox(height: 16);
