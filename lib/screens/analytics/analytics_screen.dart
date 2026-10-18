import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../utils/constants.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;
    final pending = tasks.where((t) => !t.isCompleted).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();
    final completion = tasks.isEmpty ? 0.0 : completed.length / tasks.length;

    final byCategory = <TaskCategory, int>{};
    for (final t in tasks) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: tasks.isEmpty
          ? const Center(child: Text('Add tasks to see analytics.',
              style: TextStyle(color: AppColors.gray)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ─── Summary Row ────────────────────────────────────
                Row(
                  children: [
                    _MetricCard(
                        label: 'Total', value: '${tasks.length}',
                        color: AppColors.primaryLight,
                        textColor: AppColors.primary),
                    const SizedBox(width: 10),
                    _MetricCard(
                        label: 'Done', value: '${completed.length}',
                        color: AppColors.successLight,
                        textColor: AppColors.success),
                    const SizedBox(width: 10),
                    _MetricCard(
                        label: 'Pending', value: '${pending.length}',
                        color: AppColors.warningLight,
                        textColor: AppColors.warning),
                  ],
                ),
                const SizedBox(height: 16),

                // ─── Completion Rate ─────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Completion rate',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              '${(completion * 100).round()}%',
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: completion,
                                  minHeight: 10,
                                  backgroundColor: AppColors.grayLight,
                                  valueColor: const AlwaysStoppedAnimation(
                                      AppColors.success),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ─── Priority Breakdown Bar Chart ────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tasks by priority',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barGroups: _priorityBarGroups(pending),
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) {
                                      const labels = [
                                        'Low', 'Medium', 'High', 'Critical'
                                      ];
                                      return Text(labels[v.toInt()],
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.gray));
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ─── Category Breakdown ──────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tasks by category',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        ...byCategory.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  e.key.name[0].toUpperCase() +
                                      e.key.name.substring(1),
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.gray),
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: e.value / tasks.length,
                                    minHeight: 8,
                                    backgroundColor: AppColors.grayLight,
                                    valueColor:
                                        const AlwaysStoppedAnimation(
                                            AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${e.value}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<BarChartGroupData> _priorityBarGroups(List<Task> tasks) {
    final counts = [0, 0, 0, 0]; // low, medium, high, critical
    for (final t in tasks) {
      counts[t.priorityLevel.index]++;
    }
    final colors = [
      AppColors.success, AppColors.primary,
      AppColors.warning, AppColors.danger,
    ];
    return List.generate(4, (i) => BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: counts[i].toDouble(),
          color: colors[i],
          width: 28,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    ));
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;
  const _MetricCard({
    required this.label, required this.value,
    required this.color, required this.textColor,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w600, color: textColor)),
            Text(label, style: TextStyle(
                fontSize: 12, color: textColor.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}