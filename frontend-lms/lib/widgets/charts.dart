import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../app/theme/hero_colors.dart';

FlTitlesData _titles(BuildContext context, List<String> labels, {String unit = ''}) {
  final style = TextStyle(color: context.hero.muted, fontSize: 12);
  return FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 48,
        getTitlesWidget: (value, meta) {
          // Skip the off-interval max label fl_chart adds at the top edge.
          if (value == meta.max && value % meta.appliedInterval != 0) return const SizedBox.shrink();
          return SideTitleWidget(
            meta: meta,
            child: Text('${value.toInt()}$unit', style: style, maxLines: 1, softWrap: false),
          );
        },
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          if (index < 0 || index >= labels.length || value != index.toDouble()) return const SizedBox.shrink();
          return SideTitleWidget(
            meta: meta,
            child: Text(labels[index], style: style),
          );
        },
      ),
    ),
  );
}

FlGridData _grid(BuildContext context) => FlGridData(
  drawVerticalLine: false,
  getDrawingHorizontalLine: (_) => FlLine(color: context.hero.separator, strokeWidth: 1),
);

class AttendanceChart extends StatelessWidget {
  const AttendanceChart(this.data, {super.key});

  final List<(String, double)> data;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    return Semantics(
      label: 'Attendance rate by day of the week',
      child: SizedBox(
        height: 240,
        child: LineChart(
          LineChartData(
            minY: 80,
            maxY: 100,
            gridData: _grid(context),
            borderData: FlBorderData(show: false),
            titlesData: _titles(context, [for (final point in data) point.$1], unit: '%'),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => hero.surface,
                getTooltipItems: (spots) => [
                  for (final spot in spots)
                    LineTooltipItem('${spot.y.toInt()}% present', TextStyle(color: hero.foreground, fontSize: 12)),
                ],
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].$2)],
                isCurved: true,
                color: hero.accent,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [hero.accent.withValues(alpha: 0.35), hero.accent.withValues(alpha: 0)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BarsChart extends StatelessWidget {
  const BarsChart(this.data, {super.key, required this.label, this.color, this.unit = ''});

  final List<(String, double)> data;
  final String label;
  final Color? color;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final hero = context.hero;
    return Semantics(
      label: label,
      child: SizedBox(
        height: 240,
        child: BarChart(
          BarChartData(
            gridData: _grid(context),
            borderData: FlBorderData(show: false),
            titlesData: _titles(context, [for (final bar in data) bar.$1], unit: unit),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => hero.surface,
                getTooltipItem: (group, _, rod, _) =>
                    BarTooltipItem('${rod.toY.toInt()}$unit', TextStyle(color: hero.foreground, fontSize: 12)),
              ),
            ),
            barGroups: [
              for (var i = 0; i < data.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: data[i].$2,
                      width: 28,
                      color: color ?? hero.accent,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
