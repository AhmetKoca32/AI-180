import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TodaysTipWidget extends StatelessWidget {
  final List<Map<String, dynamic>> tips;
  final int currentIndex;
  final VoidCallback onSwipe;

  const TodaysTipWidget({
    super.key,
    required this.tips,
    required this.currentIndex,
    required this.onSwipe,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'beslenme':
        return AppTheme.successLight;
      case 'koruma':
        return AppTheme.warningLight;
      case 'yaşam tarzı':
        return AppTheme.lightTheme.colorScheme.primary;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) return const SizedBox.shrink();

    final currentTip = tips[currentIndex];

    return Container(
      margin: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 2.w, bottom: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Günün İpucu',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                Row(
                  children: List.generate(
                    tips.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index == currentIndex
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSwipe,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor(
                      currentTip["category"] as String,
                    ).withValues(alpha: 0.1),
                    _getCategoryColor(
                      currentTip["category"] as String,
                    ).withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getCategoryColor(
                    currentTip["category"] as String,
                  ).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            currentTip["category"] as String,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentTip["category"] as String,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      CustomIconWidget(
                        iconName: 'lightbulb',
                        color: _getCategoryColor(
                          currentTip["category"] as String,
                        ),
                        size: 24,
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    currentTip["title"] as String,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    currentTip["content"] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daha fazla ipucu için dokunun',
                        style: AppTheme.lightTheme.textTheme.labelSmall
                            ?.copyWith(
                              color: AppTheme
                                  .lightTheme
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      CustomIconWidget(
                        iconName: 'arrow_forward',
                        color: _getCategoryColor(
                          currentTip["category"] as String,
                        ),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
