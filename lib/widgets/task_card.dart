import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import 'priority_badge.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onEdit;
  const TaskCard({super.key, required this.task, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Completion checkbox
            GestureDetector(
              onTap: () =>
                  context.read<TaskProvider>().toggleComplete(task),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted
                      ? AppColors.success
                      : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppColors.success
                        : AppColors.gray,
                    width: 1.5,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted ? AppColors.gray : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.book_outlined,
                          size: 11, color: AppColors.gray),
                      const SizedBox(width: 3),
                      Text(task.subject,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.gray)),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today_outlined,
                          size: 11, color: AppColors.gray),
                      const SizedBox(width: 3),
                      Text(
                        DateFormat('MMM d').format(task.deadline),
                        style: TextStyle(
                          fontSize: 11,
                          color: task.daysUntilDeadline <= 1
                              ? AppColors.danger
                              : AppColors.gray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Priority badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PriorityBadge(level: task.priorityLevel),
                const SizedBox(height: 4),
                Text('${task.priorityScore.toStringAsFixed(0)}pts',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.gray)),
              ],
            ),

            // Actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: AppColors.gray),
              onSelected: (v) {
                if (v == 'edit' && onEdit != null) onEdit!();
                if (v == 'delete') {
                  context.read<TaskProvider>()
                      .deleteTask(task.userId, task.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(color: AppColors.danger))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}