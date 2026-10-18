import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';

class PriorityBadge extends StatelessWidget {
  final PriorityLevel level;
  const PriorityBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (level) {
      PriorityLevel.critical => ('Critical', AppColors.dangerLight, AppColors.danger),
      PriorityLevel.high     => ('High',     AppColors.warningLight, AppColors.warning),
      PriorityLevel.medium   => ('Medium',   AppColors.primaryLight, AppColors.primary),
      PriorityLevel.low      => ('Low',      AppColors.successLight, AppColors.success),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}