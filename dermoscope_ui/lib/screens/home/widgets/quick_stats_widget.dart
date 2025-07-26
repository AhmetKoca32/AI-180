import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/theme/app_theme.dart';

class QuickStatsWidget extends StatelessWidget {
  final int weeklyCount;
  final int improvementPercentage;
  final int streakCounter;
  final bool hasAchievement;

  const QuickStatsWidget({
    super.key,
    required this.weeklyCount,
    required this.improvementPercentage,
    required this.streakCounter,
    required this.hasAchievement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 2.w, bottom: 2.h),
            child: Text(
              'Hızlı İstatistikler',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Haftalık Analiz',
                  value: weeklyCount.toString(),
                  subtitle: 'Bu hafta',
                  icon: 'analytics',
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  title: 'İyileşme',
                  value: '%$improvementPercentage',
                  subtitle: 'Son ayda',
                  icon: 'trending_up',
                  color: AppTheme.successLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.w),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Seri',
                  value: streakCounter.toString(),
                  subtitle: 'Gün üst üste',
                  icon: 'local_fire_department',
                  color: AppTheme.warningLight,
                  showBadge: hasAchievement,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  title: 'Başarı',
                  value: hasAchievement ? '🏆' : '⭐',
                  subtitle: hasAchievement ? 'Rozet kazandın!' : 'Devam et!',
                  icon: 'emoji_events',
                  color: AppTheme.accentLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required String icon,
    required Color color,
    bool showBadge = false,
  }) {
    return Container(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(iconName: icon, color: color, size: 20),
              ),
              if (showBadge)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.accentLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(title, style: AppTheme.lightTheme.textTheme.titleSmall),
          SizedBox(height: 0.5.h),
          Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
