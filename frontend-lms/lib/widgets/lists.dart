import 'package:flutter/material.dart';

import '../app/theme/hero_colors.dart';
import '../features/dashboard/mock_data.dart';
import 'hero_widgets.dart';

class ScheduleList extends StatelessWidget {
  const ScheduleList(this.entries, {super.key});

  final List<ScheduleEntry> entries;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 10,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: switch (entries[i].status) {
                            ScheduleStatus.now => hero.success,
                            ScheduleStatus.done => hero.border,
                            _ => hero.accent,
                          },
                        ),
                      ),
                      if (i < entries.length - 1) Expanded(child: Container(width: 1, color: hero.separator)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Opacity(
                    opacity: entries[i].status == ScheduleStatus.done ? 0.6 : 1,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entries[i].time,
                                  style: TextStyle(fontSize: 12, color: hero.muted, fontWeight: FontWeight.w500),
                                ),
                                Text(entries[i].title, style: const TextStyle(fontWeight: FontWeight.w500)),
                                Text(
                                  [entries[i].subtitle, ?entries[i].room].join(' · '),
                                  style: TextStyle(fontSize: 14, color: hero.muted),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (entries[i].status != null)
                            HeroChip(
                              switch (entries[i].status!) {
                                ScheduleStatus.done => 'Done',
                                ScheduleStatus.now => 'Now',
                                ScheduleStatus.next => 'Next',
                              },
                              tone: switch (entries[i].status!) {
                                ScheduleStatus.done => Tone.neutral,
                                ScheduleStatus.now => Tone.success,
                                ScheduleStatus.next => Tone.accent,
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class TaskList extends StatelessWidget {
  const TaskList(this.tasks, {super.key});

  final List<TaskEntry> tasks;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    return Column(
      children: [
        for (final task in tasks)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        task.subtitle,
                        style: TextStyle(fontSize: 12, color: hero.muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                HeroChip(task.due, tone: task.tone),
              ],
            ),
          ),
      ],
    );
  }
}
