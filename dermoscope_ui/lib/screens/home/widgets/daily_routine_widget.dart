import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DailyRoutineWidget extends StatelessWidget {
  final List<Map<String, dynamic>> routines;
  final Function(int, bool) onToggle;

  const DailyRoutineWidget({
    super.key,
    required this.routines,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = routines
        .where((routine) => routine["completed"] as bool)
        .length;
    final completionPercentage = (completedCount / routines.length * 100)
        .round();

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Günlük Rutin',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getCompletionColor(
                    completionPercentage,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '%$completionPercentage tamamlandı',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: _getCompletionColor(completionPercentage),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          LinearProgressIndicator(
            value: completionPercentage / 100,
            backgroundColor: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.2,
            ),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getCompletionColor(completionPercentage),
            ),
            minHeight: 6,
          ),
          SizedBox(height: 3.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: routines.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final routine = routines[index];
              final isCompleted = routine["completed"] as bool;

              return Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.successLight.withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.primaryContainer
                            .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted
                        ? AppTheme.successLight.withValues(alpha: 0.3)
                        : AppTheme.lightTheme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => onToggle(index, !isCompleted),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.successLight
                              : Colors.transparent,
                          border: Border.all(
                            color: isCompleted
                                ? AppTheme.successLight
                                : AppTheme.lightTheme.colorScheme.outline,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isCompleted
                            ? CustomIconWidget(
                                iconName: 'check',
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routine["task"] as String,
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: isCompleted
                                      ? AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onSurfaceVariant
                                      : AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onSurface,
                                ),
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'schedule',
                                color: AppTheme
                                    .lightTheme
                                    .colorScheme
                                    .onSurfaceVariant,
                                size: 16,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                routine["time"] as String,
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Tamamlandı',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getCompletionColor(int percentage) {
    if (percentage >= 80) return AppTheme.successLight;
    if (percentage >= 50) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }
}
